// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _uart_rx_h_
#define _uart_rx_h_

// This component will only work in xC.
#ifdef __XC__

enum uart_rx_parity {
  UART_RX_PARITY_EVEN = 0,
  UART_RX_PARITY_ODD = 1,
  UART_RX_PARITY_NONE
};

/** UART RX interface.
 *
 *   This interface provides clients access to buffer uart receive
 *   functionality.
 */
interface uart_rx_if {
  /** Get a byte from the receive buffer.
   *
   *   This function should be called after receiving a data_ready()
   *   notification.
   *   This function blocks until there is a
   *   byte available.
   */
  [[clears_notification]] unsigned char input_byte(void);


  /** Notification that data is in the receive buffer.
   *
   *   This notification function can be selected on by the client and
   *   will event when the is data in the receive buffer. After this
   *   notification the client should call the input_byte() function.
   */
  [[notification]] slave void data_ready(void);

  /** Set the baud rate of the UART RX server.
   *   The change of configuration takes place immediately.
   */
  void set_baud_rate(unsigned baud_rate);

  /** Set the parity of the UART RX server.
   *   The change of configuration takes place immediately.
   */
  void set_parity(enum uart_rx_parity parity);

  /** Set number of stop bits used by the UART RX server.
   *   The change of configuration takes place immediately.
   */
  void set_stop_bits(unsigned stop_bits);

  /** Set number of bits per byte used by the UART RX server.
   *   The change of configuration takes place immediately.
   */
  void set_bits_per_byte(unsigned bpb);
};

/** UART RX server function.
 * 
 *    This function runs a uart receive server.
 *    Bytes received by the server are buffered in the provided buffer array.
 *    When the buffer is full further incoming bytes of data will be dropped.
 *    The function never returns and will run the server idefinitely.
 *
 *    \param c      the interface connection to the server
 *    \param buffer an array to buffer incoming data into
 *    \param n      the size of the buffer
 *    \param p_rxd  the 1 bit port to input data on.
 */
void uart_rx(server interface uart_rx_if c,
             unsigned char buffer[n], unsigned n,
             in buffered port:1 p_rxd);

#endif // __XC__

#endif /* _uart_rx_h_ */
