// This file provides an example UART configuration header.
// To configure the uart module include a file like this called
// uart_rx_conf.h in your application.

/** The default/initial parity setting of a uart_rx task */
#define UART_RX_DEFAULT_PARITY UART_RX_PARITY_NONE

/** The default/initial bits per byte setting of a uart_rx task */
#define UART_RX_DEFAULT_BITS_PER_BYTE 8

/** The default/initial baud rate setting of a uart_rx task */
#define UART_RX_DEFAULT_BAUD 115200

/** The default/initial number of stop bits used by a uart_rx task */
#define UART_RX_DEFAULT_STOP_BITS 1

