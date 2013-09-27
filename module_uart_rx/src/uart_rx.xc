// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "uart_rx.h"
#include "xassert.h"
#include <xs1.h>
#include <stdio.h>
#include <print.h>

#ifdef __uart_rx_conf_h_exists__
#include "uart_rx_conf.h"
#endif

enum uart_rx_state {
  WAITING_FOR_INPUT,
  TESTING_START_BIT,
  INPUTTING_DATA_BIT,
  INPUTTING_PARITY_BIT,
  INPUTTING_STOP_BIT,
  WAITING_FOR_HIGH,
};

#ifndef UART_RX_DEFAULT_PARITY
#define UART_RX_DEFAULT_PARITY UART_RX_PARITY_NONE
#endif

#ifndef UART_RX_DEFAULT_BITS_PER_BYTE
#define UART_RX_DEFAULT_BITS_PER_BYTE 8
#endif

#ifndef UART_RX_DEFAULT_BAUD
#define UART_RX_DEFAULT_BAUD 115200
#endif

#define UART_RX_DEFAULT_BIT_TIME (XS1_TIMER_HZ / UART_RX_DEFAULT_BAUD)

#ifndef UART_RX_DEFAULT_STOP_BITS
#define UART_RX_DEFAULT_STOP_BITS 1
#endif

static inline int parity32(unsigned x, enum uart_rx_parity parity)
{
  // To compute even / odd parity the checksum should be initialised
  // to 0 / 1 respectively. The values of the uart_rx_parity have been
  // chosen so the parity can be used to initialise the checksum
  // directly.
  assert(UART_RX_PARITY_EVEN == 0);
  assert(UART_RX_PARITY_ODD == 1);
  crc32(x, parity, 1);
  return (x & 1);
}

static int add_to_buffer(unsigned char buffer[n], unsigned n,
                         int &rdptr, int &wrptr,
                         unsigned char data)
{
  int new_wrptr = wrptr + 1;

  if (new_wrptr == n)
    new_wrptr = 0;

  if (new_wrptr == rdptr) {
    // buffer full
    return 0;
  }

  buffer[wrptr] = data;
  wrptr = new_wrptr;
  return 1;
}

void uart_rx(server interface uart_rx_if c,
             unsigned char buffer[n], unsigned n,
             in buffered port:1 p_rxd)
{
  int data_bit_count;
  timer start_bit_tmr, data_bit_tmr, parity_bit_tmr, stop_bit_tmr;
  int data_trigger = 1;
  enum uart_rx_state state = WAITING_FOR_HIGH;
  int t;
  int bit_time = UART_RX_DEFAULT_BIT_TIME;
  int bits_per_byte = UART_RX_DEFAULT_BITS_PER_BYTE;
  int parity = UART_RX_DEFAULT_PARITY;
  int stop_bits = UART_RX_DEFAULT_STOP_BITS;
  int stop_bit_count;
  unsigned data;
  int rdptr = 0, wrptr = 0;
  while (1) {
    #pragma ordered
    select {

    // The following cases implement the uart state machine
    case (state == WAITING_FOR_INPUT || state == WAITING_FOR_HIGH) =>
         p_rxd when pinseq(data_trigger) :> void:
      start_bit_tmr :> t;
      t += bit_time/2;
      if (state == WAITING_FOR_HIGH) {
        data_trigger = 0;
        state = WAITING_FOR_INPUT;
      } else {
        state = TESTING_START_BIT;
      }
      break;
    case (state == TESTING_START_BIT) => start_bit_tmr when timerafter(t) :> void:
      // We should now be half way through the start bit
      // Test it is not a glitch
      int level_test;
      p_rxd :> level_test;
      if (level_test == 0) {
        data_bit_count = 0;
        t += bit_time;
        data = 0;
        state = INPUTTING_DATA_BIT;
      }
      else {
        state = WAITING_FOR_INPUT;
      }
      break;
    case (state == INPUTTING_DATA_BIT) => data_bit_tmr when timerafter(t) :> void:
      p_rxd :> >> data;
      data_bit_count++;
      t += bit_time;
      if (data_bit_count == bits_per_byte) {
        data >>= CHAR_BIT * sizeof(data) - bits_per_byte;
        if (parity != UART_RX_PARITY_NONE) {
          state = INPUTTING_PARITY_BIT;
        } else if (stop_bits != 0) {
          stop_bit_count = 0;
          state = INPUTTING_STOP_BIT;
        }
        else {
          state = WAITING_FOR_INPUT;
          data_trigger = 0;
        }
      }
      break;
    case (state == INPUTTING_PARITY_BIT) => parity_bit_tmr when timerafter(t) :> void:
      int bit;
      p_rxd :> bit;
      if (bit == parity32(data, parity)) {
        if (stop_bits != 0) {
          stop_bit_count = 0;
          state = INPUTTING_STOP_BIT;
        }
        else {
          if (add_to_buffer(buffer, n, rdptr, wrptr, data))
            c.data_ready();
          data_trigger = 0;
          state = WAITING_FOR_INPUT;
        }
      }
      else {
        state = WAITING_FOR_INPUT;
      }
      t += bit_time;
      break;
    case (state == INPUTTING_STOP_BIT) => stop_bit_tmr when timerafter(t) :> void:
      int level_test;
      p_rxd :> level_test;
      if (level_test != 1) {
        state = WAITING_FOR_INPUT;
      }
      stop_bit_count++;
      t += bit_time;
      if (stop_bit_count == stop_bits) {
        if (add_to_buffer(buffer, n, rdptr, wrptr, data)) {
          c.data_ready();
        }
        data_trigger = 0;
        state = WAITING_FOR_INPUT;
      }
      break;

    // Handle client interaction with the component
    case c.set_baud_rate(unsigned baud_rate):
      bit_time = XS1_TIMER_HZ / baud_rate;
      data_trigger = 1;
      state = WAITING_FOR_HIGH;
      break;
    case c.set_parity(enum uart_rx_parity new_parity):
      parity = new_parity;
      data_trigger = 1;
      state = WAITING_FOR_HIGH;
      break;
    case c.set_stop_bits(unsigned new_stop_bits):
      stop_bits = new_stop_bits;
      data_trigger = 1;
      state = WAITING_FOR_HIGH;
      break;
    case c.set_bits_per_byte(unsigned bpb):
      bits_per_byte = bpb;
      data_trigger = 1;
      state = WAITING_FOR_HIGH;
      break;
    [[independent_guard]]
    case (rdptr != wrptr) => c.input_byte() -> unsigned char data:
      data = buffer[rdptr];
      rdptr++;
      if (rdptr == n)
        rdptr = 0;
      if (rdptr != wrptr)
        c.data_ready();
      break;
    }
  }
}
