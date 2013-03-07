// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: app_rs485.xc
 Project : app_rs485
 Author  : XMOS Ltd
 Version : 1v0
 Purpose : This file demostrates usage of RS485 component
 -----------------------------------------------------------------------------

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/

#include <xs1.h>
#include <print.h>
#include <platform.h>
#include "rs485.h"

/*---------------------------------------------------------------------------
constants
---------------------------------------------------------------------------*/

#define DIR_BIT 0
#define BAUD 9600
#define DATA 8
#define STOP 2
#define PARITY RS485_PARITY_NONE
#define TIMEOUT 10

/*---------------------------------------------------------------------------
 Port Declaration
 ---------------------------------------------------------------------------*/

on tile[0]: rs485_interface_t rs485_if =
{
 XS1_PORT_1J,
 XS1_PORT_4E
};

rs485_config_t rs485_config =
{
  DIR_BIT,
  BAUD,
  DATA,
  STOP,
  PARITY,
  TIMEOUT
};



/** =========================================================================
 * Consume
 *
 * application thread which communcicates with the RS485 component
 *
 * \param channel to rs485_run thread, channel communication from rs485_run thread
 *
 * \return None
 *
 **/

void application(chanend c_receive, chanend c_send)
{
  unsigned char receive_buffer[RS485_BUF_SIZE];
  unsigned length_of_data;
  while(1)
  {
    if(!rs485_rx_buffer(c_receive,receive_buffer))
    {
      printstr("TX error\n");
    }
	rs485_send_packet(c_send, receive_buffer, length_of_data);
    }
}

/**
 * Top level main for multi-UART demonstration
 */

int main(void)
{
  chan c_send,c_receive;
  par
  {
    on tile[0]: application(c_receive, c_send);
    on tile[0]: rs485_run(c_send, c_receive, rs485_if, rs485_config);
  }
  return 0;
}



