// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "uart_tx.h"
#ifdef __uart_tx_conf_h_exists__
#include "uart_tx_conf.h"
#endif
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include <xscope.h>
#include "xassert.h"

#ifndef UART_TX_DEFAULT_PARITY
#define UART_TX_DEFAULT_PARITY UART_TX_PARITY_NONE
#endif

#ifndef UART_TX_DEFAULT_BITS_PER_BYTE
#define UART_TX_DEFAULT_BITS_PER_BYTE 8
#endif

#ifndef UART_TX_DEFAULT_BAUD
#define UART_TX_DEFAULT_BAUD 115200
#endif

#ifndef UART_TX_DEFAULT_BIT_TIME
#define UART_TX_DEFAULT_BIT_TIME (XS1_TIMER_HZ / UART_TX_DEFAULT_BAUD)
#endif

#ifndef UART_TX_DEFAULT_STOP_BITS
#define UART_TX_DEFAULT_STOP_BITS 1
#endif

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

[[distributable]]
void uart_tx(server interface uart_tx_if c[n], unsigned n,
             out port p_txd)
{
  int bits_per_byte = UART_TX_DEFAULT_BITS_PER_BYTE;
  int bit_time = UART_TX_DEFAULT_BIT_TIME;
  enum uart_tx_parity parity = UART_TX_DEFAULT_PARITY;
  int stop_bits = UART_TX_DEFAULT_STOP_BITS;
  timer tmr;

  p_txd <: 1;
  while (1) {
    select {
    case c[int i].output_byte(unsigned char data):
      // Trace the outgoing data
      xscope_char(UART_TX_VALUE, data);
      int t;
      // Output start bit
      p_txd <: 0;
      tmr :> t;
      t += bit_time;
      unsigned byte = data;
      // Output data bits
      for (int j = 0; j < bits_per_byte; j++) {
        tmr when timerafter(t) :> void;
        p_txd <: >> byte;
        t += bit_time;
      }
      // Output parity
      if (parity != UART_TX_PARITY_NONE) {
        tmr when timerafter(t) :> void;
        p_txd <: parity32(data, parity);
        t += bit_time;
      }
      // Output stop bits
      tmr when timerafter(t) :> void;
      p_txd <: 1;
      t += bit_time * stop_bits;
      tmr when timerafter(t) :> void;
      break;

    case c[int i].set_baud_rate(unsigned baud_rate):
      bit_time = XS1_TIMER_HZ / baud_rate;
      break;
    case c[int i].set_parity(enum uart_tx_parity new_parity):
      parity = new_parity;
      break;
    case c[int i].set_stop_bits(unsigned new_stop_bits):
      stop_bits = new_stop_bits + 1;
      break;
    case c[int i].set_bits_per_byte(unsigned bpb):
      bits_per_byte = bpb;
      break;
    }
  }
}
