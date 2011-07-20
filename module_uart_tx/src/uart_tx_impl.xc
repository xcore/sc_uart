// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <assert.h>
#include "uart_tx.h"

static inline int parity_32(unsigned x, enum uart_tx_parity parity)
{
  // To compute even / odd parity the checksum should be initialised to 0 / 1
  // respectively. The values of the uart_rx_parity have been chosen so the
  // parity can be used to initialise the checksum directly.
  assert(UART_TX_PARITY_EVEN == 0);
  assert(UART_TX_PARITY_ODD == 1);
  crc32(x, parity, 1);
  return (x & 1);
}

void uart_tx_impl_send_byte(chanend c, unsigned char byte)
{

  chkct(c, XS1_CT_END);
  outuchar(c, byte);
  outct(c, XS1_CT_END);
}

void uart_tx_impl_stop(chanend c)
{
  chkct(c, XS1_CT_END);
  outct(c, XS1_CT_END);

  chkct(c, XS1_CT_END);
  outct(c, XS1_CT_END);
}

struct buffer_state {
  int size;
  int entries;
  unsigned read_index, write_index;
};

static inline int buffer_empty(struct buffer_state &buffer_state)
{
  return buffer_state.entries == 0;
}

static inline int buffer_full(struct buffer_state &buffer_state)
{
  return buffer_state.entries == buffer_state.size;
}

/**
 * Increment the write index by one and return the old write index. The write
 * index wraps to 0 when incremented past the end of the buffer.
 */
static inline unsigned post_inc_write_index(struct buffer_state &buffer_state)
{
  unsigned index = buffer_state.write_index;
  unsigned new_index = index + 1;
  if (new_index == buffer_state.size)
    new_index = 0;
  buffer_state.entries++;
  buffer_state.write_index = new_index;
  return index;
}

/**
 * Increment the read index by one and return the old read index. The read
 * index wraps to 0 when incremented past the end of the buffer.
 */
static inline unsigned post_inc_read_index(struct buffer_state &buffer_state)
{
  unsigned index = buffer_state.read_index;
  unsigned new_index = index + 1;
  if (new_index == buffer_state.size)
    new_index = 0;
  buffer_state.entries--;
  buffer_state.read_index = new_index;
  return index;
}

#pragma select handler
static void
handle_chanend_packet(chanend c, unsigned char buffer[],
                      struct buffer_state &buffer_state,
                      int &stopping)
{
  //  unsigned char cmd;
  //  unsigned tmp;
  //  unsigned char byte;
  if (testct(c)) {
    // Shutdown
    chkct(c, XS1_CT_END);
    stopping = 1;
  } else {
    // Data.
    unsigned char byte = inuchar(c);
    chkct(c, XS1_CT_END);
    buffer[post_inc_write_index(buffer_state)] = byte;
    if (!buffer_full(buffer_state)) {
      outct(c, XS1_CT_END);
    }
  }
}

static void
pause_until_time(timer t, unsigned time, chanend c,
            unsigned char buffer[], struct buffer_state &buffer_state,
            int &stopping)
{
  while (1) {
    select {
    case handle_chanend_packet(c, buffer, buffer_state, stopping):
      break;
    case t when timerafter(time) :> void:
      return;
    }
  }
}

static void
pause_until_time_or_stopping(timer t, unsigned time, chanend c,
                             unsigned char buffer[], struct buffer_state &buffer_state,
                             int &stopping)
{
  do {
    select {
    case handle_chanend_packet(c, buffer, buffer_state, stopping):
      break;
    case t when timerafter(time) :> void:
      return;
    }
  } while (!stopping);
}

static int
get_byte_from_buffer(chanend c, unsigned char buffer[],
                     struct buffer_state &buffer_state,
                     int &stopping,
                     unsigned &byte)
{
  while (buffer_empty(buffer_state)) {
    if (stopping)
      return 0;
    select {
    #pragma xta call "call_1"
    case handle_chanend_packet(c, buffer, buffer_state, stopping):
      break;
    }
  }
  if (buffer_full(buffer_state)) {
    // Buffer is no longer full.
    #pragma xta endpoint "endpoint_4"
    outct(c, XS1_CT_END);
  }
  byte = buffer[post_inc_read_index(buffer_state)];
  return 1;
}

static void
uart_tx_impl2(out port txd, unsigned char buffer[], unsigned buffer_size,
             unsigned baud_rate, unsigned bits_per_byte,
             enum uart_tx_parity parity, unsigned stop_bits, chanend c)
{
  unsigned bit_time = XS1_TIMER_HZ / baud_rate;
  unsigned tmr_time;
  struct buffer_state buffer_state;
  int stopping = 0;
  timer t;

  buffer_state.size = buffer_size;
  buffer_state.entries = 0;
  buffer_state.read_index = 0;
  buffer_state.write_index = 0;

  // The buffer is initially empty.
  outct(c, XS1_CT_END);

  // Initial stop level
  txd <: 1;
  t :> tmr_time;

  tmr_time += bit_time * (1 + bits_per_byte + (parity != UART_TX_PARITY_NONE) +
                          stop_bits);
  pause_until_time_or_stopping(t, tmr_time, c, buffer, buffer_state, stopping);
  if (stopping)
    return;

  while (1) {
    unsigned byte, original_byte, port_time;
    // Get next byte to transmit.
    //#pragma xta label "label_1"
    if (!get_byte_from_buffer(c, buffer, buffer_state, stopping, byte))
      return;
    original_byte = byte;

    // Output start bit.
   // #pragma xta endpoint "endpoint_2"
    txd <: 0 @ port_time;
    t :> tmr_time;

    // Output data bits.
    for (int i = 0; i < bits_per_byte; i++) {
      tmr_time += bit_time;
      port_time += bit_time;
     // #pragma xta endpoint "endpoint_3"
      txd @ port_time <: >> byte;

      pause_until_time(t, tmr_time, c, buffer, buffer_state, stopping);
    }

    // Output parity bit.
    if (parity != UART_TX_PARITY_NONE) {
      tmr_time += bit_time;
      port_time += bit_time;
      #pragma xta label "label_0"
      txd @ port_time <: parity_32(original_byte, parity);

      #pragma xta call "call_0"
      pause_until_time(t, tmr_time, c, buffer, buffer_state, stopping);
    }

    // Output stop bit
    port_time += bit_time;
    tmr_time += bit_time * (stop_bits + 1);
    txd @ port_time <: 1;

    pause_until_time(t, tmr_time, c, buffer, buffer_state, stopping);
  }
}

void uart_tx_impl(out port txd, unsigned char buffer[], unsigned buffer_size,
             unsigned baud_rate, unsigned bits_per_byte,
             enum uart_tx_parity parity, unsigned stop_bits, chanend c)
{
  uart_tx_impl2(txd, buffer, buffer_size, baud_rate, bits_per_byte, parity,
               stop_bits, c);
  // Notify client of shutdown.
  outct(c, XS1_CT_END);
  chkct(c, XS1_CT_END);
}
