#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <stdlib.h>
#include <stdio.h>
#include "uart_rx.h"
// TODO remove
#include "uart_rx_impl.h"
#include "uart_tx.h"

#define BIT_RATE_0 57600
#define BIT_RATE_1 115200

#define BITTIME(x) (100000000 / (x))

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

#define TEST_ASSERT(x)\
do {\
  if (!(x)) {\
    printstr("Fail on line ");\
    printuintln(__LINE__);\
    _Exit(1);\
  }\
} while(0)

static int checkNoRxData(chanend uartRX, uart_rx_client_state &state, unsigned timeout)
{
  timer t;
  unsigned time;
  unsigned char byte;
  t :> time;
  select {
  case t when timerafter(time + timeout) :> void:
    return 1;
  case uart_rx_get_byte_byref(uartRX, state, byte):
    return 0;
  }
}

void testUART(chanend uartTX, chanend uartRX)
{
  uart_rx_client_state rxState;
  unsigned x;
  uart_rx_init(uartRX, rxState);
  // Configure RX, TX
  uart_rx_set_baud_rate(uartRX, rxState, BIT_RATE_0);
  uart_tx_set_baud_rate(uartTX, BIT_RATE_0);

  uart_tx_send_byte(uartTX, 0xff);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0xff);
  uart_tx_send_byte(uartTX, 0x00);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x00);

  // Check we can event on uart_rx_get_byte.
  {
    timer t;
    unsigned time;
    unsigned char byte;
    t :> time;
    uart_tx_send_byte(uartTX, 173);
    select {
    case t when timerafter(time + BITTIME(BIT_RATE_0) * 20) :> void:
      // Shouldn't get here.
      TEST_ASSERT(0);
      break;
    case uart_rx_get_byte_byref(uartRX, rxState, byte):
      TEST_ASSERT(byte == 173);
      break;
    }
  }

  // Reconfigure
  uart_rx_set_baud_rate(uartRX, rxState, BIT_RATE_1);
  uart_rx_set_stop_bits(uartRX, rxState, 10);
  uart_rx_set_bits_per_byte(uartRX, rxState, 7);
  uart_tx_set_baud_rate(uartTX, BIT_RATE_1);
  uart_tx_set_stop_bits(uartTX, 10);
  uart_tx_set_bits_per_byte(uartTX, 7);

  uart_tx_send_byte(uartTX, 0x12);
  uart_tx_send_byte(uartTX, 0x5a);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x12);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x5a);

  // Check parity
  uart_rx_set_parity(uartRX, rxState, UART_RX_PARITY_ODD);
  uart_rx_set_stop_bits(uartRX, rxState, 1);
  uart_rx_set_bits_per_byte(uartRX, rxState, 8);
  uart_tx_set_parity(uartTX, UART_TX_PARITY_ODD);
  uart_tx_set_stop_bits(uartTX, 1);
  uart_tx_set_bits_per_byte(uartTX, 8);

  uart_tx_send_byte(uartTX, 0x12);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x12);
  uart_tx_send_byte(uartTX, 0xa4);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0xa4);

  // Check buffering
  {
    timer t;
    unsigned time;
    unsigned char data[] = { 0xf9, 0x28, 0x2c, 0x09 };
    for (unsigned i = 0; i < ARRAY_SIZE(data); i++) {
      uart_tx_send_byte(uartTX, data[i]);
    }
    t :> time;
    t when timerafter(time + BITTIME(BIT_RATE_1) * 11 * 4) :> void;
    for (unsigned i = 0; i < ARRAY_SIZE(data); i++) {
      TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == data[i]);
    }
  }

  // Check data is discarded on incorrect parity
  uart_rx_set_parity(uartRX, rxState, UART_RX_PARITY_ODD);
  uart_tx_set_parity(uartTX, UART_TX_PARITY_EVEN);
  uart_tx_send_byte(uartTX, 0x55);
  TEST_ASSERT(checkNoRxData(uartRX, rxState, BITTIME(BIT_RATE_1) * 500));
  uart_rx_set_parity(uartRX, rxState, UART_RX_PARITY_EVEN);
  uart_tx_set_parity(uartTX, UART_TX_PARITY_ODD);
  uart_tx_send_byte(uartTX, 0x55);
  TEST_ASSERT(checkNoRxData(uartRX, rxState, BITTIME(BIT_RATE_1) * 500));

  printstrln("Pass");
  _Exit(0);
}

buffered in port:1 rx = on stdcore[0] : XS1_PORT_1A;
out port tx = on stdcore[0] : XS1_PORT_1B;

#pragma unsafe arrays
int main() {
  chan chanTX, chanRX;
  par {
    on stdcore[0] : {
      unsigned char tx_buffer[64];
      unsigned char rx_buffer[64];
      tx <: 1;
      par {
        uart_rx(rx, rx_buffer, ARRAY_SIZE(rx_buffer), BIT_RATE_0, 8, UART_TX_PARITY_NONE, 1, chanRX);
        uart_tx(tx, tx_buffer, ARRAY_SIZE(tx_buffer), BIT_RATE_0, 8, UART_TX_PARITY_NONE, 1, chanTX);
      }
    }
    on stdcore[0] : {
      testUART(chanTX, chanRX);
    }
  }
  return 0;
}
