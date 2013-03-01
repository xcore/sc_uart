// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
Filename: common.h
Project : app_rs485_demo
Author : XMOS Ltd
Version : 1v0
Purpose : This file delcares interfaces required for application
thread to communicate with rs485 component
-----------------------------------------------------------------------------

===========================================================================*/

/*---------------------------------------------------------------------------
include files
---------------------------------------------------------------------------*/
#ifndef _common_h_
#define _common_h_

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
typedefs
---------------------------------------------------------------------------*/

enum parity_state
{
	APP_RS485_PARITY_EVEN=1,
	APP_RS485_PARITY_ODD,
	APP_RS485_PARITY_NONE,
};

enum baud_state
{
	APP_RS485_BAUD_115200=1,
	APP_RS485_BAUD_57600,
	APP_RS485_BAUD_38400,
	APP_RS485_BAUD_19200,
	APP_RS485_BAUD_9600,
	APP_RS485_BAUD_4800,
	APP_RS485_BAUD_2400
};

enum data_bits_state
{
	APP_RS485_DATA_7=1,
	APP_RS485_DATA_8,
	APP_RS485_DATA_9
};

enum application_state
{
	APP_RS485_SET_BAUD		= 'b',
	APP_RS485_SET_DATA		= 'd',
	APP_RS485_SET_PARITY	= 'p',
	APP_RS485_HELP			= 'h',
	APP_RS485_SEND_DATA		= 'f'
};

unsigned char console_messages[10][220]= //Console messages to be displayed on the Comport Terminal
{
"\n** WELCOME TO RS485 COM DEMO ** \n\n -- List of supported Commands -- \n b - set baud rate \n p - set parity \n d - set data length \n h - help \n f - send data and press CTRL + D after sending data \n",
" Choose your option : ",
" \nSelect your option from the list of available baud rates :\n 1. 115200 \n 2. 57600 \n 3. 38400 \n 4. 19200 \n 5. 9600 \n 6. 4800 \n 7. 2400 \n",
" \nSelect your option from the list of available Parity :\n 1. EVEN \n 2. ODD \n 3. NONE \n ",
"\n Restart the console with New Settings. \n",
"\n Select your option from the list of available Data bits :\n 1. 7 data bits \n 2. 8 data bits \n 3. 9 data bits \n ",
"\n \n Invalid Option !!  Select Valid option. \n ",
"\n\n ------ Help ------ \n b - To Change the Baud rate of the data transfer \n p - To Change the Parity bits of the data",
"\n d - To set the Length of Data bits \n h - To Display all the help options \n f - To send stream of data and echo data back\n",
"\n Enter Data and press 'CTRL + D' after entering Data \n"
};

#endif
