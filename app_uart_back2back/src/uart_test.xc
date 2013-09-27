// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>
#include "uart_rx.h"
#include "uart_tx.h"
#include <print.h>

void test(client interface uart_tx_if c_tx,
          client interface uart_rx_if c_rx)
{
  unsigned char byte;
  printstrln("Test started");
  byte = 0;
  while (byte < 0xff) {
    printstr("Echo 10 bytes... ");
    for(int i = 0; i < 10; i++) {
      c_tx.output_byte(byte);
      byte = byte + 1;
    }
    for(int i = 0; i < 10; i++) {
      printhex(c_rx.input_byte());
    }
    printstrln(". Done.");
  }
  printstrln("Test Completed.");
}

buffered in port:1 p_rx = on stdcore[0] : XS1_PORT_1A;
out port p_tx = on stdcore[0] : XS1_PORT_1B;

#define BAUD_RATE 115200

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

int main() {
  interface uart_rx_if c_rx;
  interface uart_tx_if c_tx[1];
  par {
    on stdcore[0] : {
      unsigned char tx_buffer[64];
      uart_tx_buffered(c_tx, 1, tx_buffer, ARRAY_SIZE(tx_buffer), p_tx);
    }

    on stdcore[0] : {
      unsigned char rx_buffer[64];
      uart_rx(c_rx, rx_buffer, ARRAY_SIZE(rx_buffer), p_rx);
    }

    on stdcore[0] :  test(c_tx[0], c_rx);
  }
  return 0;
}
