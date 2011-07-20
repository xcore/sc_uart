// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <assert.h>
#include <limits.h>
#include "uart_rx_impl.h"

// TODO Provide a mechansim where the client can check for errors.
// TODO Add XTA timing pragmas.

// Force external definition of inline function in this file.
extern inline void uart_rx_get_byte_byref(chanend c, uart_rx_client_state &state, unsigned char &byte);

static inline void trap()
{
  asm("ecallf %0" : : "r"(0));
}

void uart_rx_impl_start(chanend c, uart_rx_client_state &state)
{
  state.received_bytes = 0;
  outct(c, XS1_CT_END);
  chkct(c, XS1_CT_END);
}

unsigned char uart_rx_impl_get_byte(chanend c, uart_rx_client_state &state)
{
  unsigned byte;
  byte = inuchar(c);
  chkct(c, XS1_CT_END);
  outct(c, XS1_CT_END);
  state.received_bytes++;
  return byte;
}

static inline int parity32(unsigned x, enum uart_rx_parity parity)
{
  // To compute even / odd parity the checksum should be initialised to 0 / 1
  // respectively. The values of the uart_rx_parity have been chosen so the
  // parity can be used to initialise the checksum directly.
  assert(UART_RX_PARITY_EVEN == 0);
  assert(UART_RX_PARITY_ODD == 1);
  crc32(x, parity, 1);
  return (x & 1);
}

void uart_rx_impl_stop(chanend c, uart_rx_client_state &state)
{
  outuchar(c, state.received_bytes);
  outct(c, XS1_CT_END);
  inuchar(c);
  chkct(c, XS1_CT_END);
  outct(c, XS1_CT_END);
}

struct uart_rx_options {
  unsigned bit_time;
  enum uart_rx_parity parity;
  unsigned stop_bits;
  unsigned bits_per_byte;
};

struct buffer_state {
  int size;
  int entries;
  unsigned read_index, write_index;
  int sent_bytes;
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
handle_chanend(chanend c, unsigned char buffer[],
               struct buffer_state &buffer_state,
               int &unacknowledged_byte_sent, int &stopping)
{
  #pragma xta endpoint "endpoint_0"
  if (testct(c)) {
    chkct(c, XS1_CT_END);
    if (buffer_empty(buffer_state)) {
      unacknowledged_byte_sent = 0;
    } else {
      unsigned byte = buffer[post_inc_read_index(buffer_state)];
      outuchar(c, byte);
      outct(c, XS1_CT_END);
      buffer_state.sent_bytes++;
    }
  } else {
    unsigned received_bytes = inuchar(c);
    stopping = 1;
    chkct(c, XS1_CT_END);
    // There may be data sitting in the channel in either direction.
    // We need to clear out any data sent to the server and ensure that there
    // is a byte of data for the client to input.
    if (unacknowledged_byte_sent) {
      // There are two possibilities here. Either the server has output a byte
      // which hasn't been received by the client or the client has output an
      // acknowledgement that hasn't been received by the server due to the
      // stop request overtaking the acknowledgement. We differentiate between
      // these possiblities by comparing the number of bytes sent by the
      // server to the number received by the client.
      if (buffer_state.sent_bytes == received_bytes) {
        chkct(c, XS1_CT_END);
        outuchar(c, 0);
        outct(c, XS1_CT_END);
      } else {
        // Do nothing
      }
    } else {
      outuchar(c, 0);
      outct(c, XS1_CT_END);
    }
    #pragma xta endpoint "endpoint_1"
    chkct(c, XS1_CT_END);
  }
}

static void
add_to_buffer(unsigned byte, chanend c, unsigned char buffer[],
              struct buffer_state &buffer_state,
              int &unacknowledged_byte_sent)
{
  if (buffer_empty(buffer_state) && !unacknowledged_byte_sent) {
    outuchar(c, byte);
    outct(c, XS1_CT_END);
    unacknowledged_byte_sent = 1;
    buffer_state.sent_bytes++;
  } else if (!buffer_full(buffer_state)) {
    buffer[post_inc_write_index(buffer_state)] = byte;
  } else {
    // Overrun.
	  trap();
  }
}

static void
pause_until_pinseq(unsigned value, in buffered port:1 rxd, chanend c,
                   unsigned char buffer[], struct buffer_state &buffer_state,
                   int &unacknowledged_byte_sent, int &stopping)
{
  do {
    select {
    case rxd when pinseq(value) :> void:
      return;
    case handle_chanend(c, buffer, buffer_state, unacknowledged_byte_sent, stopping):
      break;
    }
  } while (!stopping);
}

static void
pause_until_time(unsigned time, timer t, chanend c, unsigned char buffer[],
                 struct buffer_state &buffer_state,
                 int &unacknowledged_byte_sent, int &stopping)
{
  do {
    select {
    case t when timerafter(time) :> void:
      return;
    case handle_chanend(c, buffer, buffer_state, unacknowledged_byte_sent, stopping):
      break;
    }
  } while (!stopping);
}

void
uart_rx_impl(in buffered port:1 rxd, unsigned char buffer[],
             unsigned buffer_size, unsigned baud_rate, unsigned bits_per_byte,
             enum uart_rx_parity parity, unsigned stop_bits, chanend c)
{
  struct buffer_state buffer_state;
  int unacknowledged_byte_sent = 0;
  int stopping = 0;
  unsigned bit_time = XS1_TIMER_HZ / baud_rate;
  timer t;

  buffer_state.size = buffer_size;
  buffer_state.entries = 0;
  buffer_state.read_index = 0;
  buffer_state.write_index = 0;
  buffer_state.sent_bytes = 0;

  // Wait for start packet.
  chkct(c, XS1_CT_END);
  outct(c, XS1_CT_END);

  // Wait for pins to go high before we look for the start bit.
  pause_until_pinseq(1, rxd, c, buffer,
                     buffer_state, unacknowledged_byte_sent, stopping);
  if (stopping)
    return;

  while (1) {
    int data_valid;
    unsigned byte, time;
    unsigned level_test;
    // wait for negative edge of start bit.
    pause_until_pinseq(0, rxd, c, buffer,
                       buffer_state, unacknowledged_byte_sent, stopping);
    if (stopping)
      return;

    // move time into centre of bit.
    t :> time;
    time += bit_time / 2;

    pause_until_time(time, t, c, buffer,
                     buffer_state, unacknowledged_byte_sent, stopping);
    if (stopping)
      return;

    // Ensure start bit wasn't a glitch.
    rxd :> level_test;
    if (level_test != 0)
      continue;

    // input data bits.
    for (int i = 0; i < bits_per_byte; i++) {
      time += bit_time;
      pause_until_time(time, t, c, buffer,
                       buffer_state, unacknowledged_byte_sent, stopping);
      if (stopping)
        return;
      rxd :> >> byte;
    }
    byte >>= CHAR_BIT * sizeof(byte) - bits_per_byte;

    // input parity.
    if (parity != UART_RX_PARITY_NONE) {
      unsigned parity_bit;
      time += bit_time;
      pause_until_time(time, t, c, buffer,
                       buffer_state, unacknowledged_byte_sent, stopping);
      if (stopping)
        return;
      rxd :> parity_bit;
      data_valid = parity_bit == parity32(byte, parity);
    } else {
      data_valid = 1;
    }

    // input stop bits.
    for (int i = 0; i < stop_bits; i++) {
      time += bit_time;
      pause_until_time(time, t, c, buffer,
                       buffer_state, unacknowledged_byte_sent, stopping);
      if (stopping)
        return;
      rxd :> level_test;
      // Check stop bit is valid.
      if (level_test != 1) {
        // Wait for pins to go high before we look for the start bit again.
        pause_until_pinseq(1, rxd, c, buffer,
                           buffer_state, unacknowledged_byte_sent, stopping);
        if (stopping)
          return;
        data_valid = 0;
        break;
      }
    }

    if (data_valid) {
      add_to_buffer(byte, c, buffer, buffer_state, unacknowledged_byte_sent);
    }
  }
}
