#include <xs1.h>
#include <print.h>
#include <platform.h>
#include <xscope.h>
#include "uart_rx.h"

on tile[1] : buffered in port:1 p_rx = XS1_PORT_1G;

#define RX_BUFFER_SIZE 64
static unsigned char rx_buffer[RX_BUFFER_SIZE];

void xscope_user_init(void) {
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
}

void demo(client interface uart_rx_if c_uart_rx)
{
  printstrln("Echoing incoming uart bytes");
  c_uart_rx.set_baud_rate(115200);
  c_uart_rx.set_parity(UART_RX_PARITY_EVEN);
  c_uart_rx.set_bits_per_byte(8);
  c_uart_rx.set_stop_bits(1);
  while (1) {
    select {
    case c_uart_rx.data_ready():
      unsigned char val = c_uart_rx.input_byte();
      printchar(val);
      break;
    }
  }
}

int main(void) {
  interface uart_rx_if c_uart_rx;

  par {
    on tile[1] : uart_rx(c_uart_rx, rx_buffer, RX_BUFFER_SIZE, p_rx);
    on tile[1] : demo(c_uart_rx);
  }
  return 0;
}
