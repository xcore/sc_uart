// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>
#include "uart_rx.h"
#include "uart_tx.h"
#include <print.h>

void forward(chanend uartTX, chanend uartRX)
{
  uart_rx_client_state rxState;
  unsigned char rcvbuffer[10];
  unsigned char byte;
  int i;
  unsigned int gotest;
  gotest=1;
  byte=0;
  printstr("uartRX Init...\n");  
  uart_rx_init(uartRX, rxState);
  while(gotest) {
    printstr("Echo 10 bytes...");
    for(i=0;i<10;i++) {
      uart_tx_send_byte(uartTX, byte);
      byte =  byte + 1;
      if(byte==0xFF) {
        gotest=0;
      }
    }
    for(i=0;i<10;i++) {
      rcvbuffer[i] = uart_rx_get_byte(uartRX, rxState);
    }
    for(i=0;i<10;i++) {
      printhex(rcvbuffer[i]);
      printstr(" ");
    } 
    printstr("done\n");
  }
  printstr("Test Completed\n");
}

buffered in port:1 rx = on stdcore[0] : XS1_PORT_1A;
out port tx = on stdcore[0] : XS1_PORT_1B;

#define BAUD_RATE 115200

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

#pragma unsafe arrays
int main() {
  chan chanTX, chanRX;
  par {
    on stdcore[0] : {
      unsigned char tx_buffer[64];
      unsigned char rx_buffer[64];
      tx <: 1;
      printstr("Test Start...\n");
      par {
        uart_rx(rx, rx_buffer, ARRAY_SIZE(rx_buffer), BAUD_RATE, 8, UART_TX_PARITY_NONE, 1, chanRX);
        uart_tx(tx, tx_buffer, ARRAY_SIZE(tx_buffer), BAUD_RATE, 8, UART_TX_PARITY_NONE, 1, chanTX);
      }
    }
    on stdcore[0] : {
      forward(chanTX, chanRX);
    }
  }
  return 0;
}
