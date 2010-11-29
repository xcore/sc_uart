#ifndef _uart_rx_h_
#define _uart_rx_h_

enum uart_rx_parity {
  UART_RX_PARITY_EVEN = 0,
  UART_RX_PARITY_ODD = 1,
  UART_RX_PARITY_NONE
};

typedef struct {
  unsigned received_bytes;
} uart_rx_client_state;

/**
 * UART RX server function. The client must call the uart_rx_init() function
 * to initialize the server before calling any other client functions.
 * The client may then reconfigure server using uart_rx_set_baud_rate(),
 * uart_rx_set_parity(), uart_rx_set_stop_bits(), uart_rx_set_bits_per_byte().
 * Bytes received by the server are buffered in the \a buffer array. When the
 * buffer is full further incoming bytes of data will be dropped by the server
 * The client uses uart_rx_get_byte() to get bytes from the receive buffer.
 * This function never returns.
 */
void uart_rx(in buffered port:1 rxd, unsigned char buffer[],
             unsigned buffer_size, unsigned baud_rate, unsigned bits,
             enum uart_rx_parity parity, unsigned stop_bits,
             chanend c);

/**
 * Initializes the UART server and the client state structure.
 */
void uart_rx_init(chanend c, uart_rx_client_state &state);

/**
 * Get a byte from the receive buffer. This function blocks until there is a
 * byte available.
 */
unsigned char uart_rx_get_byte(chanend c, uart_rx_client_state &state);

/**
 * Get a byte from the receive buffer. This function blocks until there is a
 * byte available.
 */
#pragma select handler
void uart_rx_get_byte_byref(chanend c, uart_rx_client_state &state,
                            unsigned char &byte);

/**
 * Set the baud rate of the UART RX server. The change of configuration takes
 * place immediately. Any data currently in the receive buffer is discarded.
 */
void uart_rx_set_baud_rate(chanend c, uart_rx_client_state &state, unsigned baud_rate);

/**
 * Set the parity of the UART RX server. The change of configuration takes
 * place immediately. Any data currently in the receive buffer is discarded.
 */
void uart_rx_set_parity(chanend c, uart_rx_client_state &state, enum uart_rx_parity parity);

/**
 * Set number of stop bits used by the UART RX server. The change of
 * configuration takes place immediately. Any data currently in the receive
 * buffer is discarded.
 */
void uart_rx_set_stop_bits(chanend c, uart_rx_client_state &state, unsigned stop_bits);

/**
 * Set number of bits per byte used by the UART RX server. The change of
 * configuration takes place immediately. Any data currently in the receive
 * buffer is discarded.
 */
void uart_rx_set_bits_per_byte(chanend c, uart_rx_client_state &state, unsigned bits);

#endif /* _uart_rx_h_ */
