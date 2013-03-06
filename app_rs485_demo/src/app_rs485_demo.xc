// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: app_rs485_demo.xc
 Project : app_rs485_demo
 Author : XMOS Ltd
 Version : 1v0
 Purpose : This file implements demostration RS485 component
 -----------------------------------------------------------------------------

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include <xs1.h>
#include <print.h>
#include <xscope.h>
#include <platform.h>
#include <string.h>
#include "rs485.h"
#include "common.h"

/*---------------------------------------------------------------------------
 ports
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
 TIMEOUT,
};

/** =========================================================================
 * application
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

    unsigned char buf_rx[RS485_BUF_SIZE]; //Buffer stores received data
    unsigned len, result;
    unsigned char exit_command_mode=0,select_valid_option=0, end_of_data=0,index_len=0,length=0,data;

    result = rs485_send_packet(c_send, console_messages[0], strlen(console_messages[0])); //Displays welcome message on the terminal
    while(1)
    {
		rs485_send_byte(c_send, '\n');
		c_receive :> len;
		c_receive :> data;
		switch(data)
		{
			case APP_RS485_SET_BAUD: //Baud Rate settings

				select_valid_option=0;
				while(select_valid_option == 0)
				{
					select_valid_option=1;
					result = rs485_send_packet(c_send, console_messages[2], strlen(console_messages[2])); //Displays message on the terminal
					c_receive :> len;
					c_receive :> data;
					data=data-'0';
					if(data > 0 && data <8)
						result = rs485_send_packet(c_send, console_messages[4], strlen(console_messages[4]));
					switch(data)
					{
						case APP_RS485_BAUD_115200: //Set Baud as 115200
							rs485_set_baud(c_send, 115200);
							break;

						case APP_RS485_BAUD_57600: //Set Baud as 57600
							rs485_set_baud(c_send, 57600);
							break;

						case APP_RS485_BAUD_38400: //Set Baud as 38400
							rs485_set_baud(c_send, 38400);
							break;

						case APP_RS485_BAUD_19200: //Set Baud as 19200
							rs485_set_baud(c_send, 19200);
							break;

						case APP_RS485_BAUD_9600: //Set Baud as 9600
							rs485_set_baud(c_send, 9600);
							break;

						case APP_RS485_BAUD_4800: //Set Baud as 4800
							rs485_set_baud(c_send, 4800);
							break;

						case APP_RS485_BAUD_2400: //Set Baud as 2400
							rs485_set_baud(c_send, 2400);
							break;

						default:
							result = rs485_send_packet(c_send, console_messages[6], strlen(console_messages[6])); //Displays messgae as Invalid user selection
							select_valid_option=0;
							break;
					}
				}
			break;

			case APP_RS485_SET_PARITY: //Update Parity information
				select_valid_option=0;
				while(select_valid_option == 0)
				{
					select_valid_option=1;
					result = rs485_send_packet(c_send, console_messages[3], strlen(console_messages[3]));
					result = rs485_send_packet(c_send, console_messages[1], strlen(console_messages[1]));
					c_receive :> len;
					c_receive :> data;
					data=data-'0';
					if(data > 0 && data <4)
						result = rs485_send_packet(c_send, console_messages[4], strlen(console_messages[4]));
					switch(data)
					{
						case APP_RS485_PARITY_EVEN: // Set EVEN Parity
							rs485_set_parity(c_send,RS485_PARITY_EVEN);
						break;

						case APP_RS485_PARITY_ODD: //Set ODD Parity
							rs485_set_parity(c_send,RS485_PARITY_ODD);
						break;

						case APP_RS485_PARITY_NONE: //Set Parity as NONE
							rs485_set_parity(c_send,RS485_PARITY_NONE);
						break;

						default: //Displays Invalid user selection
							result = rs485_send_packet(c_send, console_messages[6], strlen(console_messages[6]));
							select_valid_option=0;
							break;
					}
				}

			break;

			case APP_RS485_SET_DATA: //Set the length of number of data bits for transmission
				select_valid_option=0;
				while(select_valid_option == 0)
				{
					select_valid_option=1;
					result = rs485_send_packet(c_send, console_messages[2], strlen(console_messages[2]));
					result = rs485_send_packet(c_send, console_messages[1], strlen(console_messages[1]));
					c_receive :> len;
					c_receive :> data;
					data=data-'0';
					if(data > 0 && data <4)
						result = rs485_send_packet(c_send, console_messages[4], strlen(console_messages[4]));
					switch(data)
					{
						case APP_RS485_DATA_7: //Sets Data bits length as 7
							rs485_set_data_bits(c_send,7);
						break;

						case APP_RS485_DATA_8: //Sets Data bits length as 8
							rs485_set_data_bits(c_send,8);
						break;

						case APP_RS485_DATA_9: //Sets Data bits length as 9
							rs485_set_data_bits(c_send,9);
						break;

						default: //Displays Invalid selection on the terminal
							result = rs485_send_packet(c_send, console_messages[6], strlen(console_messages[6]));
							select_valid_option=0;
							break;
					}
				}
			break;

			case APP_RS485_HELP: //Displays help information on the screen
				result = rs485_send_packet(c_send, console_messages[7], strlen(console_messages[7]));
				result = rs485_send_packet(c_send, console_messages[8], strlen(console_messages[8]));
			break;

			case APP_RS485_SEND_DATA: //Receives the input data still user presses CTRL + D and displays the received send data back to the terminal
				end_of_data=0;
				result = rs485_send_packet(c_send, console_messages[9], strlen(console_messages[9]));
				while(end_of_data != 1)
				{
					c_receive :> len;
					length=0;
					while( length != len)
					{
						length++;
						c_receive :> data;
						if(data == 4)
							end_of_data=1;
						if(index_len < RS485_BUF_SIZE)
							buf_rx[index_len++]=data; //update all the received data into buffrer
					}
				}
				result = rs485_send_packet(c_send, buf_rx, index_len);
				index_len=0;
				break;

			default: //Displays invalid option in the Terminal
				result = rs485_send_packet(c_send, console_messages[6], strlen(console_messages[6]));
				break;
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
		on tile[0]:{application(c_receive, c_send);}
		   on tile[0]: rs485_run(c_send, c_receive, rs485_if, rs485_config);
	}
	return 0;
}


