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
 * UART TX server function. This function never returns. The arguments specify
 * the initial configuration. The configuration may be changed with the 
 * uart_tx_send_byte(), uart_tx_set_baud_rate(), uart_tx_set_parity(),
 * uart_tx_set_stop_bits() and uart_tx_set_bits_per_byte(). The client should
 * provide data to the server using the uart_tx_send_byte() function.
 * \param rxd Transmitted data signal. Must be a 1-bit port.
 * \param buffer Array for buffering bytes before they are transmitted.
 * \param buffer_size Size of the \a buffer array.
 * \param baud_rate Initial baud rate.
 * \param bits Initial bits per character. Must be less than 8.
 * \param parity Type of parity to initially use. No parity bit is transmitted
 *               if \a UART_TX_PARITY_NONE is passed.
 * \param stop_bits Initial number of stop bits to transmit.
 * \param c Chanend to receive requests on, where a request is either a byte
 *          to transmit or a configuration change.
 */
void uart_tx(out port txd, unsigned char buffer[], unsigned buffer_size,
             unsigned baud_rate, unsigned bits, enum uart_tx_parity parity,
             unsigned stop_bits, chanend c);

/**
 * Adds a byte into the UART transmit buffer. If the the buffer is full then
 * this function blocks until there is room in the buffer.
 * \param chanend Other end of the channel passed to the uart_tx()
 *                function.
 * \param byte Byte to transmit.
 */
#pragma select handler
void uart_tx_send_byte(chanend c, unsigned char byte);

/**
 * Set the baud rate of the UART TX server. The change of configuration takes
 * effect after all remaining data in transmit buffer is sent. This function
 * blocks until the change of configuration takes effect.
 * \param chanend Other end of the channel passed to the uart_tx()
 *                function.
 * \param baud_rate The baud rate.
 */
void uart_tx_set_baud_rate(chanend c, unsigned baud_rate);

/**
 * Set the type of parity used by the UART TX server. The change of
 * configuration takes effect after all remaining data in transmit buffer is
 * sent. This function blocks until the change of configuration takes effect.
 * \param chanend Other end of the channel passed to the uart_tx()
 *                function.
 * \param parity The type of parity.
 */
void uart_tx_set_parity(chanend c, enum uart_tx_parity parity);

/**
 * Set number of stop bits used by the UART TX server. The change of
 * configuration takes effect after all remaining data in transmit buffer is
 * sent. This function blocks until the change of configuration takes effect.
 * \param chanend Other end of the channel passed to the uart_tx()
 *                function.
 * \param stop_bits The number of stop bits to use.
 */
void uart_tx_set_stop_bits(chanend c, unsigned stop_bits);

/**
 * Set number of bits per byte used by the UART TX server. The change of
 * configuration takes effect after all remaining data in transmit buffer is
 * sent. This function blocks until the change of configuration takes effect.
 * \param chanend Other end of the channel passed to the uart_tx()
 *                function.
 * \param bits The number of bits per byte.
 */
void uart_tx_set_bits_per_byte(chanend c, unsigned bits);


#endif
