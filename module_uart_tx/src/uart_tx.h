// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __UART_TX__
#define __UART_TX__

/** Enum for the type of parity to use when transmitting data. */
enum uart_tx_parity {
  UART_TX_PARITY_EVEN = 0,
  UART_TX_PARITY_ODD = 1,
  UART_TX_PARITY_NONE
};

/** Interface for communicating with UART transmit components. */
typedef interface uart_tx_if {
  /** Output a byte via UART.
   *
   *  This function outputs a byte over the serial port. It will block until
   *  either the byte is transmitted (in the unbuffered case) or until there is
   *  space in the component's transmit buffer.
   *
   * \param data    The byte to transmit
   *
   */
  void output_byte(unsigned char data);

  /** Set the baud rate of the of the UART transmit component.
   *
   *  The change of configuration takes effect immediately and the behaviour
   *  with regard to any remaining bytes in the transmit buffer is undefined.
   *
   *   \param baud_rate     The baud rate setting
   */
  void set_baud_rate(unsigned baud_rate);

  /** Set the parity of the of the UART transmit component.
   *
   *  The change of configuration takes effect immediately and the behaviour
   *  with regard to any remaining bytes in the transmit buffer is undefined.
   *
   *   \param parity     The parity setting
   */
  void set_parity(enum uart_tx_parity parity);

  /** Set the stop bits of the of the UART transmit component.
   *
   *  The change of configuration takes effect immediately and the behaviour
   *  with regard to any remaining bytes in the transmit buffer is undefined.
   *
   *   \param stop_bits   The number of stop bits
   */
  void set_stop_bits(unsigned stop_bits);

  /** Set the bits per byte of the of the UART transmit component.
   *
   *  The change of configuration takes effect immediately and the behaviour
   *  with regard to any remaining bytes in the transmit buffer is undefined.
   *
   *   \param bpb     The bits per byte value
   */
  void set_bits_per_byte(unsigned bpb);
} uart_tx_if;

/** An unbuffered UART transmit component.
 *
 *  This function runs forever and provides an unbuffered uart transmit
 *  component. It can be distributed amongst other logical cores so does not
 *  need its own core unless a client is on a different tile.
 *  Multiple clients can connect to the component.
 *
 *  \param c      Array of interfaces to connect to
 *  \param n      The number of clients (i.e. the size of c)
 *  \param p_txd  The output port
 */
[[distributable]]
void uart_tx(server interface uart_tx_if c[n], unsigned n,
             out port p_txd);

/** A buffered UART transmit component.
 *
 *  This function runs forever and provides a buffered uart transmit
 *  component. Data output to the component will be placed in a buffer (of
 *  configurable size) and subsequently transmitted. Unlike the unbuffered
 *  component, this function requires a logical core to output
 *  data from the buffer independently of the clients
 *
 *  \param c      Array of interfaces to connect to
 *  \param n      The number of clients (i.e. the size of c)
 *  \param buffer The array to use as a buffer
 *  \param m      The size of the buffer (number of characters)
 *  \param p_txd  The output port
 *
 */
void uart_tx_buffered(server interface uart_tx_if c[n], unsigned n,
                      unsigned char buffer[m], unsigned m,
                      out port p_txd);

#endif // __UART_TX__
