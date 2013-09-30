// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>
#include <stdlib.h>
#include "uart_rx.h"
#include "uart_tx.h"
#include "debug_print.h"
#include "xassert.h"

#define BIT_RATE_MAX 115200
#define BITTIME(x) (100000000 / (x))

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))


#define CHECK_EVENTS 1
#define CHECK_BUFFERING 1
#define CHECK_RUNTIME_PARAMETER_CHANGE 1
#define CHECK_PARITY_ERRORS 1

static void check_no_rx_data(client interface uart_rx_if c_uart_rx,
                             unsigned timeout)
{
  timer t;
  unsigned time;
  t :> time;
  select {
  case t when timerafter(time + timeout) :> void:
    return;
  case c_uart_rx.data_ready():
    fail("unexpected data");
    break;
  }
  __builtin_unreachable();
}

void uart_test(client interface uart_tx_if c_uart_tx,
               client interface uart_rx_if c_uart_rx,
               unsigned baud_rate)
{
  unsigned char byte;
  timer t;
  unsigned time;

  // Configure RX, TX
  c_uart_rx.set_baud_rate(baud_rate);
  c_uart_rx.set_stop_bits(1);
  c_uart_rx.set_bits_per_byte(8);
  c_uart_rx.set_parity(UART_RX_PARITY_NONE);
  c_uart_tx.set_baud_rate(baud_rate);
  c_uart_tx.set_stop_bits(1);
  c_uart_tx.set_bits_per_byte(8);
  c_uart_tx.set_parity(UART_TX_PARITY_NONE);

  debug_printf("baud rate = %d\n",baud_rate);

  debug_printf("Performing basic loopback test.\n");
  c_uart_tx.output_byte(0x0);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x0);

  c_uart_tx.output_byte(0x2c);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x2c);

  c_uart_tx.output_byte(0x0A);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x0A);

  c_uart_tx.output_byte(0x04);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x04);

#if CHECK_EVENTS
  debug_printf("Check we can event on incoming data.\n");
  t :> time;
  c_uart_tx.output_byte(173);
  select {
    case t when timerafter(time + BITTIME(baud_rate) * 20) :> void:
      // Shouldn't get here.
      fail("timeout (data not ready)");
      break;
    case c_uart_rx.data_ready():
      byte = c_uart_rx.input_byte();
      xassert(byte == 173);
      break;
  }
#endif

#if CHECK_BUFFERING
  unsigned char data[] = { 0x11, 0x00, 0x2c, 0x09};
  debug_printf("Testing buffering of %d bytes.\n", ARRAY_SIZE(data));
  for (unsigned i = 0; i < ARRAY_SIZE(data); i++) {
    c_uart_tx.output_byte(data[i]);
  }
  t :> time;
  t when timerafter(time + BITTIME(baud_rate) * 11 * 4) :> void;
  for (unsigned i = 0; i < ARRAY_SIZE(data); i++) {
    byte = c_uart_rx.input_byte();
    xassert(byte == data[i]);
  }
#endif

#if CHECK_RUNTIME_PARAMETER_CHANGE
  // Reconfigure
  debug_printf("Reconfiguring UART.\n");

  c_uart_rx.set_baud_rate(baud_rate/2);
  c_uart_rx.set_stop_bits(10);
  c_uart_rx.set_bits_per_byte(7);
  c_uart_tx.set_baud_rate(baud_rate/2);
  c_uart_tx.set_stop_bits(10);
  c_uart_tx.set_bits_per_byte(7);

  c_uart_tx.output_byte(0x12);
  c_uart_tx.output_byte(0x5a);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x12);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x5a);

  debug_printf("Reconfiguring parity to odd.\n");
  // Check parity
  c_uart_rx.set_bits_per_byte(8);
  c_uart_tx.set_bits_per_byte(8);
  c_uart_rx.set_parity(UART_RX_PARITY_ODD);
  c_uart_tx.set_parity(UART_TX_PARITY_ODD);
  c_uart_tx.output_byte(0x12);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x12);
  c_uart_tx.output_byte(0xa4);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0xa4);

  debug_printf("Reconfiguring parity to even.\n");
  // Check parity
  c_uart_rx.set_parity(UART_RX_PARITY_EVEN);
  c_uart_tx.set_parity(UART_TX_PARITY_EVEN);
  c_uart_tx.output_byte(0x12);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0x12);
  c_uart_tx.output_byte(0xa4);
  byte = c_uart_rx.input_byte();
  xassert(byte == 0xa4);

  debug_printf("Reconfiguring back ..\n");
  c_uart_rx.set_baud_rate(baud_rate);
  c_uart_rx.set_stop_bits(1);
  c_uart_rx.set_bits_per_byte(8);
  c_uart_rx.set_parity(UART_RX_PARITY_NONE);
  c_uart_tx.set_baud_rate(baud_rate);
  c_uart_tx.set_stop_bits(1);
  c_uart_tx.set_bits_per_byte(8);
  c_uart_tx.set_parity(UART_TX_PARITY_NONE);

#endif

#if CHECK_PARITY_ERRORS
  debug_printf("Checking that invalid parity information is discarded.\n");
  c_uart_rx.set_parity(UART_RX_PARITY_ODD);
  c_uart_tx.set_parity(UART_TX_PARITY_EVEN);
  c_uart_tx.output_byte(0x55);
  check_no_rx_data(c_uart_rx, BITTIME(baud_rate) * 200);

  c_uart_rx.set_parity(UART_RX_PARITY_EVEN);
  c_uart_tx.set_parity(UART_TX_PARITY_ODD);
  c_uart_tx.output_byte(0x55);
  check_no_rx_data(c_uart_rx, BITTIME(baud_rate) * 200);
#endif

  debug_printf("Pass\n");
}

buffered in port:1 p_rx = on tile[0] : XS1_PORT_1A;
out port p_tx = on tile[0] : XS1_PORT_1B;


#define N 64
int main() {
  interface uart_rx_if c_rx;
  interface uart_tx_if c_tx[1];

  par {
    on tile[0] : {
      unsigned char tx_buffer[N];
      uart_tx_buffered(c_tx, 1, tx_buffer, N, p_tx);
    }

    on tile[0] : {
      unsigned char rx_buffer[N];
      uart_rx(c_rx, rx_buffer, N, p_rx);
    }

    on tile[0] : {
      unsigned rates[] = {115200, 2400, 9600, 19200};
      for (int i = 0; i < ARRAY_SIZE(rates); i++)
        uart_test(c_tx[0], c_rx, rates[i]);
      _Exit(0);
    }
  }
  return 0;
}
