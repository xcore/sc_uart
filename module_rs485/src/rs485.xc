// Copyright (c) 2013, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

///////////////////////////////////////////////////////////////////////////////

#include <xs1.h>
#include <assert.h>
#include <platform.h>
#include "rs485.h"

int buffer_index;

int parity32(unsigned x, enum rs485_parity parity)
{
  // To compute even / odd parity the checksum should be initialised to 0 / 1
  // respectively. The values of the uart_rx_parity have been chosen so the
  // parity can be used to initialise the checksum directly.
  assert(RS485_PARITY_EVEN == 0);
  assert(RS485_PARITY_ODD == 1);
  crc32(x, parity, 1);
  return (x & 1);
}

int add_to_buffer(unsigned data, unsigned buffer[], int buffer_size)
{
	if(buffer_index + 1>= buffer_size)
	{
		return RS485_BUFFER_STATE_OVERRUN;
	}else{
		buffer[buffer_index] = data;
		buffer_index ++;
		return RS485_BUFFER_STATE_OK;
	}
}

void rs485_run(port pData, out port pDir, unsigned dir_bit, chanend cControl, chanend cData,
				unsigned baud_rate, int data_bits, int stop_bits, enum rs485_parity parity, int data_timeout)
{

	enum rs485_state state;
	int t, data_valid;
	unsigned c, level_test, u;

	unsigned int data = 0;
	timer tim;
	int timeout, timer_enabled = 0;

	unsigned clocks = XS1_TIMER_HZ / baud_rate;
	int dt2 = (clocks * 3)>>1;
	int dt = clocks;


	unsigned buffer[RS485_BUF_SIZE];
	buffer_index = 0;
	state = RS485_STATE_SETUP;

	buffer_index = 0;
	pDir <: 0;
	state = RS485_STATE_RX_IDLE;
	while(1)
	{
		select
		{
			case pData when pinseq(0) :> int _ @ t:
				// receive started
				state = RS485_STATE_RX;
				// set/reset packet timer
				tim :> timeout;
				timeout += (clocks * (data_bits + stop_bits + 1)) * data_timeout;
				timer_enabled = 1;

				t += dt2;
				// receive data bits
				for(int i = 0; i < data_bits; i++) {

					pData @ t :> >> data;
					t += dt;
				}
				data >>= 32 - data_bits;
				// receive parity
				if(parity != RS485_PARITY_NONE)
				{
					unsigned parity_bit;

					pData @ t :> parity_bit;
					t += dt;
					data_valid = parity_bit == parity32(data, parity);
				}else{
					data_valid = 1;
				}
				// receive stop bits
				for(int i = 0; i < stop_bits; i++){

					pData @ t :> level_test;
					t += dt;
					if(level_test != 1)
					{
						data_valid = 0;

					}
				}

				if(data_valid)
				{
					// add data to buffer
					if(add_to_buffer(data, buffer, RS485_BUF_SIZE) == RS485_BUFFER_STATE_OK)
					{
						state = RS485_STATE_RX;
					}else{
						state = RS485_STATE_RX_ERROR;
						//handle error
					}
				}else{

					// data valid error
					state = RS485_STATE_RX_ERROR;
					// handle error
				}

				break;

			case cControl :> c:
				switch(c)
				{
					case RS485_CMD_SET_BAUD :
							if(state != RS485_STATE_RX && state != RS485_STATE_TX)
							{
								cControl :> baud_rate;
								clocks = XS1_TIMER_HZ / baud_rate;
								dt2 = (clocks * 3)>>1;
								dt = clocks;
								cControl <: baud_rate;
							}else{
								cControl :> u;
								cControl <: 0;
							}
						break;

					case RS485_CMD_SET_BITS :
						if(state != RS485_STATE_RX && state != RS485_STATE_TX)
						{
							cControl :> data_bits;
							cControl <: data_bits;
						}else{
							cControl :> u;
							cControl <: 0;
						}
						break;

					case RS485_CMD_SET_PARITY :
						if(state != RS485_STATE_RX && state != RS485_STATE_TX)
						{
							cControl :> parity;
							cControl <: parity;
						}else{
							cControl :> u ;
							cControl <: 0;
						}
						break;

					case RS485_CMD_SET_STOP_BITS :
						if(state != RS485_STATE_RX && state != RS485_STATE_TX)
						{
							cControl :> stop_bits;
							cControl <: stop_bits;
						}else{
							cControl :> u;
							cControl <: 0;
						}
						break;

					case RS485_CMD_SEND_BYTE :
						if(state != RS485_STATE_RX && state != RS485_STATE_TX)
						{
							unsigned char b, original_byte;
							cControl :> b;
							original_byte = b;
							// send a byte
							state = RS485_STATE_TX;
							// set the tranciever to TX direction
							pDir <: 1 << dir_bit;
							pData <: 1 @ t;
							t += dt;
							pData @ t <: 0 ;
							t += dt;
							for(int i = 0; i < data_bits; i++) {
								pData @ t <: >> b;
								t += dt;
							}

							//parity
							if(parity != RS485_PARITY_NONE)
							{
								pData @ t <: parity32(original_byte, parity);
								t += dt;
							}
							//stop bits
							for(int i=0; i < stop_bits; i++)
							{
								pData @ t <: 1;
								t += dt;
							}
							pDir @ t <: 0;
							cControl <: 1;
							pData :> void;
							state = RS485_STATE_RX_IDLE;

						}else{
							cControl :> u;
							cControl <: 0;
						}
						break;

					case RS485_CMD_SEND_PACKET:
						if(state != RS485_STATE_RX && state != RS485_STATE_TX)
						{
							unsigned char len, b, original_byte;
							cControl :> len;
							state = RS485_STATE_TX;
							// set the tranciever to TX direction
							pDir <: 1 << dir_bit;
							// TX ready
							pData <: 1 @ t;
							t += dt;
							for(int i=0; i<len; i++)
							{
								cControl :> b;
								original_byte = b;
								pData @ t <: 0 ;
								t += dt;
								for(int j = 0; j < data_bits; j++) {
									pData @ t <: >> b;
									t += dt;
								}

								//parity
								if(parity != RS485_PARITY_NONE)
								{
									pData @ t <: parity32(original_byte, parity);
									t += dt;
								}
								//stop bits
								for(int i=0; i < stop_bits; i++)
								{
									pData @ t <: 1;
									t += dt;
								}
							}
							pDir @ t <: 0;
							cControl <: len;
							pData :> void;
							state = RS485_STATE_RX_IDLE;
						}
						break;

					case RS485_CMD_GET_STATUS :
						cControl <: state;
						break;
				}
				break;

			case timer_enabled => tim when timerafter(timeout) :> void :
				timer_enabled = 0;
				state = RS485_STATE_RX_DONE;
				// send buffer
				cData <: buffer_index;
				for(int i=0; i<buffer_index; i++)
				{
					cData <: buffer[i];
				}
				buffer_index = 0;
				state = RS485_STATE_RX_IDLE;
				break;
		}
	}
}

int rs485_set_baud(chanend c, int baud)
{
	int ret;
	c <: RS485_CMD_SET_BAUD;
	c <: baud;
	c :> ret;
	if(ret == baud)
	{
		return 1;
	}else{
		return 0;
	}
}

int rs485_set_data_bits(chanend c, int data_bits)
{
	int ret;
	c <: RS485_CMD_SET_BITS;
	c <: data_bits;
	c :> ret;
	if(ret == data_bits)
	{
		return 1;
	}else{
		return 0;
	}
}

int rs485_set_stop_bits(chanend c, int stop_bits)
{
	int ret;
	c <: RS485_CMD_SET_STOP_BITS;
	c <: stop_bits;
	c :> ret;
	if(ret == stop_bits)
	{
		return 1;
	}else{
		return 0;
	}
}

int rs485_set_parity(chanend c, enum rs485_parity parity)
{
	enum rs485_parity ret;
	c <: RS485_CMD_SET_PARITY;
	c <: parity;
	c :> ret;
	if(ret == parity)
	{
		return 1;
	}else{
		return 0;
	}
}

int rs485_get_status(chanend c)
{
	int ret;
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

int rs485_send_packet(chanend c, unsigned char data[], unsigned len)
{
	int ret;
	c <: RS485_CMD_SEND_PACKET;
	c <: len;
	for(int i = 0; i < len; i++) {
		c <: data[i];
	}
	c :> ret;
	if(ret == len)
	{
		return 1;
	}else{
		return 0;
	}
}
