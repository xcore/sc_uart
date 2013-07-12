// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "uart_tx.h"
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include <print.h>
#include "xassert.h"

enum uart_tx_state {
  WAITING_FOR_DATA,
  OUTPUTTING_DATA_BIT,
  OUTPUTTING_PARITY_BIT,
  OUTPUTTING_STOP_BIT
};

#define DEFAULT_PARITY UART_TX_PARITY_NONE
#define DEFAULT_BITS_PER_BYTE 8
#define DEFAULT_BAUD 115200
#define DEFAULT_BIT_TIME (XS1_TIMER_HZ / DEFAULT_BAUD)
#define DEFAULT_STOP_BITS 1

static inline int parity32(unsigned x, enum uart_tx_parity parity)
{
  // To compute even / odd parity the checksum should be initialised
  // to 0 / 1 respectively. The values of the art_tx_parity have been
  // chosen so the parity can be used to initialise the checksum
  // directly.
  assert(UART_TX_PARITY_EVEN == 0);
  assert(UART_TX_PARITY_ODD == 1);
  crc32(x, parity, 1);
  return (x & 1);
}

static inline int buffer_full(int rdptr, int wrptr, int buf_length)
{
  wrptr++;
  if (wrptr == buf_length)
    wrptr = 0;
  return (wrptr == rdptr);
}

static inline void init_transmit(unsigned char buffer[buf_length], unsigned buf_length,
                                 int &rdptr, int &wrptr, out port p_txd,
                                 enum uart_tx_state &state,
                                 int &bit_count, int &t,
                                 int bit_time,
                                 unsigned &byte)
{
  timer tmr;
  if (state != WAITING_FOR_DATA || rdptr == wrptr)
    return;
  byte = buffer[rdptr];
  rdptr++;
  if (rdptr == buf_length)
    rdptr = 0;
  state = OUTPUTTING_DATA_BIT;
  bit_count = 0;
  // Output start bit
  p_txd <: 0;
  tmr :> t;
  t += bit_time;
}

void uart_tx_buffered(server interface uart_tx_if c[n], unsigned n,
                      unsigned char buffer[buf_length], unsigned buf_length,
                      out port p_txd)
{
  int bits_per_byte = DEFAULT_BITS_PER_BYTE;
  int bit_time = DEFAULT_BIT_TIME;
  enum uart_tx_parity parity = DEFAULT_PARITY;
  int stop_bits = DEFAULT_STOP_BITS;

  enum uart_tx_state state = WAITING_FOR_DATA;
  unsigned byte;
  int bit_count, stop_bit_count;
  timer data_bit_tmr, parity_bit_tmr, stop_bit_tmr;

  int rdptr = 0, wrptr = 0;

  int t;
  p_txd <: 1;
  while (1) {
    #pragma ordered
    select {
    case (state == OUTPUTTING_DATA_BIT) => data_bit_tmr when timerafter(t) :> void:
      p_txd <: (byte >> bit_count);
      t += bit_time;
      bit_count++;
      if (bit_count == bits_per_byte) {
        if (parity != UART_TX_PARITY_NONE) {
          state = OUTPUTTING_PARITY_BIT;
        } else if (stop_bits != 0) {
          stop_bit_count = 0;
          state = OUTPUTTING_STOP_BIT;
        } else {
          state = WAITING_FOR_DATA;
          init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                        bit_count, t, bit_time, byte);
        }
      }
      break;
    case (state == OUTPUTTING_PARITY_BIT) => parity_bit_tmr when timerafter(t) :> void:
      int val = parity32(byte, parity);
      p_txd <: val;
      t += bit_time;
      if (stop_bits != 0) {
        stop_bit_count = 0;
        state = OUTPUTTING_STOP_BIT;
      } else {
        state = WAITING_FOR_DATA;
        init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                      bit_count, t, bit_time, byte);
      }
      break;
    case (state == OUTPUTTING_STOP_BIT) => stop_bit_tmr when timerafter(t) :> void:
      p_txd <: 1;
      t += bit_time;
      stop_bit_count++;
      if (stop_bit_count == stop_bits) {
        state = WAITING_FOR_DATA;
        init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                      bit_count, t, bit_time, byte);
      }
      break;

    // Handle client interaction with the component
    case !buffer_full(rdptr, wrptr, buf_length) => c[int i].output_byte(unsigned char data):
      buffer[wrptr] = data;
      wrptr++;
      if (wrptr == buf_length)
        wrptr = 0;
      init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                    bit_count, t, bit_time, byte);
      break;
    case c[int i].set_baud_rate(unsigned baud_rate):
      bit_time = XS1_TIMER_HZ / baud_rate;
      state = WAITING_FOR_DATA;
      init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                    bit_count, t, bit_time, byte);
      break;
    case c[int i].set_parity(enum uart_tx_parity new_parity):
      parity = new_parity;
      state = WAITING_FOR_DATA;
      init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                    bit_count, t, bit_time, byte);

      break;
    case c[int i].set_stop_bits(unsigned new_stop_bits):
      stop_bits = new_stop_bits + 1;
      state = WAITING_FOR_DATA;
      init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                    bit_count, t, bit_time, byte);
      break;
    case c[int i].set_bits_per_byte(unsigned bpb):
      bits_per_byte = bpb;
      state = WAITING_FOR_DATA;
      init_transmit(buffer, buf_length, rdptr, wrptr, p_txd, state,
                    bit_count, t, bit_time, byte);
      break;
    }
  }
}
