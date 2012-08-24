// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _uart_tx_impl_h_
#define _uart_tx_impl_h_

#include "uart_tx.h"

/**
 * UART TX server function with no support for reconfiguration. This function
 * can be stopped by the client calling uart_tx_impl_stop().  The client should
 * provide data to the server using the uart_tx_impl_send_byte() function.
 * \param txd         Transmitted data signal. Must be a 1-bit port.
 * \param buffer      Array for buffering bytes before they are transmitted.
 * \param buffer_size Size of the \a buffer array.
 * \param baud_rate   Baud rate.
 * \param bits        Bits per character. Must be less than 8.
 * \param parity      Type of parity to use. No parity bit is transmitted if a UART_TX_PARITY_NONE is passed.
 * \param stop_bits   Number of stop bits to transmit.
 * \param c           Chanend to receive requests on, where a request is either a byte to transmit or a configuration change.
 */
void uart_tx_impl(out port txd, unsigned char buffer[], unsigned buffer_size,
                  unsigned baud_rate, unsigned bits, enum uart_tx_parity parity,
                  unsigned stop_bits, chanend c);

/**
 * Adds a byte into the UART transmit buffer. If the the buffer is full
 * uart_tx_impl_send_byte() blocks until there is room in the buffer.
 * uart_tx_impl_send_byte() can be used in a case of a select function in which
 * case is ready when there is room in the UART transmit buffer.
 * \param c     Other end of the channel passed to the uart_tx_impl() function.
 * \param byte  Byte to transmit.
 */
#pragma select handler
void uart_tx_impl_send_byte(chanend c, unsigned char byte);

/**
 * Stops the UART TX server. The uart_tx_impl() server function will transmit
 * all remaining data in its buffer before returning. This function blocks until
 * the server has stopped.
 * \param c     Other end of the channel passed to the uart_tx_impl() function.
 */
void uart_tx_impl_stop(chanend c);

#endif /* _uart_tx_impl_h_ */
