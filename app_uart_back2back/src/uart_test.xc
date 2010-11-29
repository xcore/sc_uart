#include <xs1.h>
#include <platform.h>
#include "uart_rx.h"
#include "uart_tx.h"

void forward(chanend uartTX, chanend uartRX)
{
  uart_rx_client_state rxState;
  uart_rx_init(uartRX, rxState);
  while(1) {
    unsigned byte = uart_rx_get_byte(uartRX, rxState);
    uart_tx_send_byte(uartTX, byte);
  }
}

buffered in port:1 rx = PORT_UART_RX;
out port tx = PORT_UART_TX;

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
