// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "uart_rx.h"
#include "uart_rx_impl.h"
#include <xs1.h>
#include <stdio.h>

static inline void trap()
{
  asm("ecallf %0" : : "r"(0));
}

struct uart_rx_options {
  unsigned baud_rate;
  enum uart_rx_parity parity;
  unsigned stop_bits;
  unsigned bits_per_byte;
};

enum {
  UART_RX_SET_BAUD_RATE_PKT,
  UART_RX_SET_PARITY_PKT,
  UART_RX_SET_STOP_BITS_PKT,
  UART_RX_SET_BITS_PER_BYTE_PKT,
};

#pragma select handler
static transaction
handle_config_chanend(chanend c,
                      struct uart_rx_options &options)
{
  unsigned char cmd;
  //  unsigned tmp;
  c :> cmd;
  switch (cmd) {
#pragma fallthrough
  default:
    // Should't get here.
    trap();
  case UART_RX_SET_BAUD_RATE_PKT:
    c:> options.baud_rate;
    break;
  case UART_RX_SET_PARITY_PKT:
    c:> options.parity;
    break;
  case UART_RX_SET_STOP_BITS_PKT:
    c:> options.stop_bits;
    break;
  case UART_RX_SET_BITS_PER_BYTE_PKT:
    c:> options.bits_per_byte;
    break;
  }
}

void uart_rx(in buffered port:1 rxd, unsigned char buffer[],
                unsigned buffer_size, unsigned baud_rate, unsigned bits,
                enum uart_rx_parity parity, unsigned stop_bits,
                chanend c)
{
  struct uart_rx_options options;

  options.baud_rate = baud_rate;
  options.bits_per_byte = bits;
  options.parity = parity;
  options.stop_bits = stop_bits;

  //printf("parity = %d\n",options.parity);

  while (1) {
    uart_rx_impl(rxd, buffer, buffer_size, options.baud_rate,
                 options.bits_per_byte, options.parity, options.stop_bits,
                 c);
    slave handle_config_chanend(c, options);
  }
}

unsigned char uart_rx_get_byte(chanend c, uart_rx_client_state &state)
{
  return uart_rx_impl_get_byte(c, state);
}

void uart_rx_get_byte_byref(chanend c, uart_rx_client_state &state,
                                   unsigned char &byte)
{
  byte = uart_rx_impl_get_byte(c, state);
}

void uart_rx_init(chanend c, uart_rx_client_state &state) {
  uart_rx_impl_start(c, state);
}

void uart_rx_set_baud_rate(chanend c, uart_rx_client_state &state, unsigned baud_rate)
{
  uart_rx_impl_stop(c, state);
  master {
    c <: (unsigned char)UART_RX_SET_BAUD_RATE_PKT;
    c <: baud_rate;
  };
  uart_rx_impl_start(c, state);
}

void uart_rx_set_parity(chanend c, uart_rx_client_state &state, enum uart_rx_parity parity)
{
  uart_rx_impl_stop(c, state);
  master {
    c <: (unsigned char)UART_RX_SET_PARITY_PKT;
    c <: parity;
  };
  uart_rx_impl_start(c, state);
}

void uart_rx_set_stop_bits(chanend c, uart_rx_client_state &state, unsigned stop_bits)
{
  uart_rx_impl_stop(c, state);
  master {
    c <: (unsigned char)UART_RX_SET_STOP_BITS_PKT;
    c <: stop_bits;
  };
  uart_rx_impl_start(c, state);
}

void uart_rx_set_bits_per_byte(chanend c, uart_rx_client_state &state, unsigned bits)
{
  uart_rx_impl_stop(c, state);
  master {
    c <: (unsigned char)UART_RX_SET_BITS_PER_BYTE_PKT;
    c <: bits;
  };
  uart_rx_impl_start(c, state);
}
