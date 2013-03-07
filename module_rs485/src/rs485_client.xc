// Copyright (c) 2013, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
///////////////////////////////////////////////////////////////////////////////

#include "rs485.h"
#include <xs1.h>
#include <platform.h>

int rs485_rx_buffer(chanend c_receive, unsigned char receive_buffer[])
{
  unsigned length_of_data;
  c_receive :> length_of_data; //receives length of data from the rs485_run thread
  for (int i = 0; i < length_of_data; i++)
  {
    c_receive :> receive_buffer[i];
  }
  return length_of_data;
}

int rs485_set_baud(chanend c, int baud)
{
  int ret;
  c <: RS485_CMD_SET_BAUD;
  c <: baud;
  c :> ret;
  return (ret == baud);
}

int rs485_set_data_bits(chanend c, int data_bits)
{
  int ret;
  c <: RS485_CMD_SET_BITS;
  c <: data_bits;
  c :> ret;
  return (ret == data_bits);
}

int rs485_set_stop_bits(chanend c, int stop_bits)
{
  int ret;
  c <: RS485_CMD_SET_STOP_BITS;
  c <: stop_bits;
  c :> ret;
  return (ret == stop_bits);
}

int rs485_set_parity(chanend c, rs485_parity_t parity)
{
  rs485_parity_t ret;
  c <: RS485_CMD_SET_PARITY;
  c <: parity;
  c :> ret;
  return (ret == parity);
}

rs485_state_t rs485_get_status(chanend c)
{
  rs485_parity_t ret;
  c <: RS485_CMD_GET_STATUS;
  c :> ret;
  return ret;
}

int rs485_send_byte(chanend c, unsigned char data)
{
  int ret;
  c <: RS485_CMD_SEND_BYTE;
  c <: data;
  c :> ret;
  return ret;
}

#pragma unsafe arrays
int rs485_send_packet(chanend c, unsigned char data[], unsigned len)
{
  int ret;
  c <: RS485_CMD_SEND_PACKET;
  c <: len;
  for (int i = 0; i < len; i++)
  {
    c <: (unsigned)data[i];
  }
  c :> ret;
  return (ret == len);
}
