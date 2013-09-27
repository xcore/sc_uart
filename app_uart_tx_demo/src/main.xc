#include <xs1.h>
#include <print.h>
#include <platform.h>
#include <xscope.h>
#include "uart_tx.h"

on tile[1] : out port p_tx = XS1_PORT_1C;

void xscope_user_init(void) {
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
}

void demo(client interface uart_tx_if c_uart_tx)
{
  c_uart_tx.set_baud_rate(115200);
  c_uart_tx.set_parity(UART_TX_PARITY_EVEN);
  c_uart_tx.set_bits_per_byte(8);
  c_uart_tx.set_stop_bits(1);

  timer tmr;
  int t;
  tmr :> t;

  printstrln("Outputting hello world every second");
  while (1) {
    select {
    case tmr when timerafter(t) :> void:
      const char msg[] = "Hello World\r\n";
      int i = 0;
      while (msg[i] != '\0') {
        c_uart_tx.output_byte(msg[i]);
        i++;
      }
      t += 100000000;
      break;
    }
  }
}

#if UART_TX_BUFFERED
#define BUF_LEN 20
static unsigned char buffer[BUF_LEN];
#endif

int main(void) {
  interface uart_tx_if c_uart_tx[1];

  par {
    #if UART_TX_BUFFERED
    on tile[1] : uart_tx_buffered(c_uart_tx, 1, buffer, BUF_LEN, p_tx);
    #else
    on tile[1] : [[distribute]] uart_tx(c_uart_tx, 1, p_tx);
    #endif
    on tile[1] : demo(c_uart_tx[0]);
  }
  return 0;
}
