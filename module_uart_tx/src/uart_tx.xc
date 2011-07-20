// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "uart_tx_impl.h"
#include "uart_tx.h"
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>

struct uart_tx_options {
  unsigned baud_rate;
  unsigned bits_per_byte;
  enum uart_tx_parity parity;
  unsigned stop_bits;
};
extern void Dump_error();
enum {
  UART_TX_SET_BAUD_RATE_PKT,
  UART_TX_SET_PARITY_PKT,
  UART_TX_SET_STOP_BITS_PKT,
  UART_TX_SET_BITS_PER_BYTE_PKT,
};

static inline void trap()
{
  asm("ecallf %0" : : "r"(0));
}

static transaction
handle_config_packet(chanend c, struct uart_tx_options &options)
{
  unsigned char cmd;
  //  unsigned tmp;
  c :> cmd;
  switch (cmd) {
  #pragma fallthrough
  default:
    // Should't get here.
    trap();
  case UART_TX_SET_BAUD_RATE_PKT:
    c :> options.baud_rate;
    break;
  case UART_TX_SET_PARITY_PKT:
    c :> options.parity;
    break;
  case UART_TX_SET_STOP_BITS_PKT:
    c :> options.stop_bits;
    break;
  case UART_TX_SET_BITS_PER_BYTE_PKT:
    c :> options.bits_per_byte;
    break;
  }
}

void uart_tx(out port txd, unsigned char buffer[], unsigned buffer_size,
                     unsigned baud_rate, unsigned bits, enum uart_tx_parity parity,
                     unsigned stop_bits, chanend c)
{
  struct uart_tx_options options;

  options.baud_rate = baud_rate;
  options.bits_per_byte = bits;
  options.parity = parity;
  options.stop_bits = stop_bits;



  while (1) {
	  if(stop_bits > 2)
	  {
		   printf("Incorrect stop bits.Fail\n");
		  _Exit(1);
	  }
	  if(parity>3)
	  {
		   printf("Incorrect parity.Fail\n");
		  _Exit(1);
	  }
	  if((bits<5) || (bits>8))
	  {
		   printf("Incorrect bitsperbyte .Fail\n");
		  _Exit(1);
	  }
      if((baud_rate!=115200) && (baud_rate!= 96000) && (baud_rate!=24000) && (baud_rate!= 57600))
      {
		   printf("Incorrect baud_rate .Fail\n");
		  _Exit(1);
      }

    uart_tx_impl(txd, buffer, buffer_size, options.baud_rate, options.bits_per_byte, options.parity, options.stop_bits, c);
    //printf("buffer = %x\n",buffer[0]);
    //printf("buffer_size = %d\n",buffer_size);
    slave handle_config_packet(c, options);
  }
}

void uart_tx_send_byte(chanend c, unsigned char byte)
{
  uart_tx_impl_send_byte(c, byte);
}

void uart_tx_set_baud_rate(chanend c, unsigned baud_rate)
{
  uart_tx_impl_stop(c);
  master {
    c <: (unsigned char)UART_TX_SET_BAUD_RATE_PKT;
    c <: baud_rate;
  };
}

void uart_tx_set_parity(chanend c, enum uart_tx_parity parity)
{
  uart_tx_impl_stop(c);
  master {
    c <: (unsigned char)UART_TX_SET_PARITY_PKT;
    c <: parity;
  };
}

void uart_tx_set_stop_bits(chanend c, unsigned stop_bits)
{
  uart_tx_impl_stop(c);
  master {
    c <: (unsigned char)UART_TX_SET_STOP_BITS_PKT;
    c <: stop_bits;
  };
}

void uart_tx_set_bits_per_byte(chanend c, unsigned bits)
{
  uart_tx_impl_stop(c);
  master {
    c <: (unsigned char)UART_TX_SET_BITS_PER_BYTE_PKT;
    c <: bits;
  };
}

// Force external definition of inline function in this file.
extern inline void uart_tx_send_byte(chanend c, unsigned char byte);
