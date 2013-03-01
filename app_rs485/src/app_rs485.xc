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
#include <xscope.h>
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

on tile[0]: port p_Data = XS1_PORT_1J;
on tile[0]: out port p_Dir = XS1_PORT_4E;

/** =========================================================================
 * Consume
 *
 * consume thread which communcicates with the RS485 component
 *
 * \param channel to rs485_run thread, channel communication from rs485_run thread
 *
 * \return None
 *
 **/

void consume(chanend c_receive, chanend c_send)
{
    unsigned char receive_buffer[RS485_BUF_SIZE];
    unsigned length_of_data;
    unsigned result;

    while(1)
    {
		c_receive :> length_of_data; //receives length of dayta from the rs485_run thread
		for(int i = 0; i < length_of_data; i++)
		{
		  c_receive :> receive_buffer[i];
		  receive_buffer[i] += 1; //manuplates the received data and stores in the buffer
		}
		result = rs485_send_packet(c_send, receive_buffer, length_of_data);
		if(!result)
		{
			printstr("TX error\n");
		}
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
		on tile[0]:{consume(c_receive, c_send);}
		on tile[0]:{rs485_run(p_Data, p_Dir, DIR_BIT, c_send, c_receive, BAUD, DATA, STOP, PARITY, TIMEOUT);}
	}
	return 0;
}


