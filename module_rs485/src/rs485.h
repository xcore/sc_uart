// Copyright (c) 2013, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

///////////////////////////////////////////////////////////////////////////////

#ifndef RS485_H_
#define RS485_H_
#include <xccompat.h>
#ifdef __xtcp_client_conf_h_exists__
#include "rs485_conf.h"
#endif
#ifndef RS485_BUF_SIZE
#define RS485_BUF_SIZE (40)
#endif

#ifdef __XC__
typedef struct rs485_interface_t_
{
  port p_data;
  out port p_dir;
}rs485_interface_t;
#endif

typedef enum rs485_parity_t_
{
  RS485_PARITY_EVEN = 0,
  RS485_PARITY_ODD,
  RS485_PARITY_NONE
} rs485_parity_t;

typedef enum rs485_state_t_
{
  RS485_STATE_SETUP,
  RS485_STATE_RX_IDLE,
  RS485_STATE_RX,
  RS485_STATE_RX_DONE,
  RS485_STATE_RX_ERROR,
  RS485_STATE_TX,
  RS485_STATE_TX_DONE
} rs485_state_t;

typedef enum rs485_cmd_t_
{
  RS485_CMD_SET_BAUD,
  RS485_CMD_SET_BITS,
  RS485_CMD_SET_PARITY,
  RS485_CMD_SET_STOP_BITS,
  RS485_CMD_SEND_BYTE,
  RS485_CMD_GET_STATUS,
  RS485_CMD_SEND_PACKET
} rs485_cmd_t;

typedef enum rs485_buffer_state_t_
{
  RS485_BUFFER_STATE_EMPTY,
  RS485_BUFFER_STATE_OVERRUN,
  RS485_BUFFER_STATE_OK
} rs485_buffer_state_t;

typedef struct rs485_config_t_
{
  unsigned dir_bit;
  unsigned baud_rate;
  int data_bits;
  int stop_bits;
  rs485_parity_t parity;
  int data_timeout;
}rs485_config_t;

/** Implemetation of a half-duplex RS485 interface. This function requires an unbuffered 1-bit port for the
 * bi-directional RS485 data channel, and one bit of a 4-bit port to set the data direction. Setting the
 * direction bit low will put the channel in to receive mode, and setting high will put it in transmit mode.
 * The function also requires two channels, one for control and the other for received data.
 *
 * The default state of the channel is to go in to revceive mode and wait for a start bit. Once reception has
 * started a timeout is set, the timeout is reset for each data byte received. On expiration of the timeout (no
 * data recieved in the elapsed time) the received packet is transferred via the data channel.
 *
 * The operating parameters (stop bits, data bits, parity and baud) can be changed using commands on the command
 * channel.
 *
 * On a 62.5 MIPS core this fucntion shold be able to support 1 Mbps transmission rate.
 *
 * This function does not return.
 *
 * \param pData        bi-directional 1-bit port, used for reception and transmission of data
 * \param pDir		   output port, 4 bit port, one bit of which is used for direction control
 * \param dir_bit	   The bit value of the 4-bit port used for the direction control
 * \param cControl     The control channel
 * \param cData	       The data channel for received data
 * \param baud_rate    The baud rate (bps)
 * \param data_bits    The number of data bits
 * \param stop_bits	   The number of stop bits (whole integer)
 * \param parity       The parity option (enum rs485_parity type)
 * \param data_timeout The number of character times after the last received character to indiacte packet finish
 *
 */
#if __XC__
void rs485_run(chanend c_control,
               chanend c_data,
               rs485_interface_t &rs485_if,
               rs485_config_t &rs485_config);
#endif

/** receieve data and store in buffer.
 *
 * Receives data and stores in the buffer.
 * Only whole integer numbers are supported.
 *
 * \param c    The command interface channel
 * \param buffer[] The receive buffer
 *
 */
void rs485_rx_buffer(chanend c_receive, unsigned char receive_buffer[]);

/** Set the baud rate.
 *
 * Sets the baud rate of the RS485.
 * Only whole integer numbers are supported.
 *
 * \param c    The command interface channel
 * \param baud The baud rate (bps)
 *
 */
int rs485_set_baud(chanend c, int baud);

/** Set the number of data bits.
 *
 * Sets the number of data bits for the RS485.
 * Only whole integer numbers are supported.
 *
 * \param c         The command interface channel
 * \param data_bits The number of data bits
 *
 */

int rs485_set_data_bits(chanend c, int data_bits);

/** Set the number of stop bits.
 *
 * Sets the number of stop bits for the RS485.
 * Only whole integer numbers are supported.
 *
 * \param c         The command interface channel
 * \param stop_bits The number of stop bits
 *
 */

int rs485_set_stop_bits(chanend c, int stop_bits);

/** Set the parity.
 *
 * Sets the parity option for the RS485.
 *
 * \param c      The command interface channel
 * \param parity The parity option, type rs485_parity
 *
 */

int rs485_set_parity(chanend c, rs485_parity_t parity);

/** Get the current status.
 *
 * Returns the current status of the RS485.
 * Will return one of rs485_state
 *
 * \param c The command interface channel
 *
 */

rs485_state_t rs485_get_status(chanend c);
/** Transmit one byte.
 *
 * Transmit a single byte MSB first
 * Return 0 if TX is not possible, 1 if TX successful
 *
 * \param c    The command interface channel
 * \param data The byte to transmit
 *
 */

int rs485_send_byte(chanend c, unsigned char data);

/** Transmit specified number of bytes.
 *
 * Most significant bit first order.
 * Big endian byte order.
 * Return 0 if TX is not possible, 1 if TX successful
 *
 * \param c    The command interface channel
 * \param data The array of data to transmit
 * \param len  The number of bytes to transmit,
 *             this must not be greater than the size of buffer
 *
 */

int rs485_send_packet(chanend c, unsigned char data[], unsigned len);

#endif
