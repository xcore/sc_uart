// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef UART_VIRTUAL_TX
#define UART_VIRTUAL_TX

/** 
 * \file uart_tx.h
 * \brief UART TX component.
 *
 * This file contains functions to make use of the UART TX component.
 */

/** Enum for the type of parity to use when transmitting data. */
enum uart_tx_parity {
  UART_TX_PARITY_EVEN = 0,
  UART_TX_PARITY_ODD = 1,
  UART_TX_PARITY_NONE
};


/**
 * UART TX server function. 
 * This function never returns and the arguments specify the initial configuration of parity, bits per byte etc.
 * These are checked and then the inner UART TX loop (uart_tx_impl() is started and runs in a while(1) loop until 
 * it receives and instruction to shut down via the channel from the client. Additionally a set of client functions 
 * are provided to transmit a byte and to alter the baud rate, parity, bits per byte and stop bit settings. Note that
 * the buffer size can only be changed when this function is first called, it cannot be changed thereafter.
 *
 * The client provides data to the server using the send byte function below.
 * 
 * Arguments are as follows:
 *
 * \param txd          Transmitted data signal. Must be a 1-bit port.
 * \param buffer       Array for buffering bytes before they are transmitted.
 * \param buffer_size  Size of the \a buffer array.
 * \param baud_rate    Initial baud rate.
 * \param bits         Initial bits per character. Must be less than 8.
 * \param parity       Type of parity to initially use. No parity bit is transmitted if \a UART_TX_PARITY_NONE is passed.
 * \param stop_bits    Initial number of stop bits to transmit.
 * \param c            Chanend to receive requests on, where a request is either a byte to transmit or a configuration change.
 */
void uart_tx(out port txd, unsigned char buffer[], unsigned buffer_size,
             unsigned baud_rate, unsigned bits, enum uart_tx_parity parity,
             unsigned stop_bits, chanend c);

#pragma select handler

/**
 * Adds a byte into the UART transmit buffer. If the the buffer is full then this function blocks until there is room in the buffer.
 * \param c            Other end of the channel passed to the uart_tx() function.
 * \param byte         Byte to transmit.
 */

void uart_tx_send_byte(chanend c, unsigned char byte);

/**
 * Set the baud rate of the of the UART TX server. 
 * The change of configuration takes effect after all remaining data in transmit buffer is sent, and the function
 * blocks until the change of configuration takes effect.
 *
 * \param c             Other end of the channel passed to the uart_tx() function.
 * \param baud_rate     The baud rate setting. 
 */
void uart_tx_set_baud_rate(chanend c, unsigned baud_rate);

/**
 * Set the parity of the of the UART TX stop bit. 
 * The change of configuration takes effect after all remaining data in transmit buffer is sent, and the function
 * blocks until the change of configuration takes effect.
 *
 * \param c             Other end of the channel passed to the uart_tx() function.
 * \param parity     The parity setting. Note parity is an enum.
 */
void uart_tx_set_parity(chanend c, enum uart_tx_parity parity);

/**
 * Set the number of stop bits used by the UART TX server. 
 * The change of configuration takes effect after all remaining data in transmit buffer is sent, and the function
 * blocks until the change of configuration takes effect.
 *
 * \param c             Other end of the channel passed to the uart_tx() function.
 * \param stop_bits     The stop bits or bits-per-byte setting. Note parity is an enum.
 */
void uart_tx_set_stop_bits(chanend c, unsigned stop_bits);

/**
 * Set the bits per byte rate of the of the UART TX server. 
 * The change of configuration takes effect after all remaining data in transmit buffer is sent, and the function
 * blocks until the change of configuration takes effect.
 *
 * \param c             Other end of the channel passed to the uart_tx() function.
 * \param bits          The bits or bits-per-byte setting.
 */
void uart_tx_set_bits_per_byte(chanend c, unsigned bits);


#endif
