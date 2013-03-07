// Copyright (c) 2013, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
///////////////////////////////////////////////////////////////////////////////

#include "rs485.h"
#include <xs1.h>
#include <platform.h>

static int parity32(unsigned x, rs485_parity_t parity)
{
  // To compute even / odd parity the checksum should be initialised to 0 / 1
  // respectively. The values of the uart_rx_parity have been chosen so the
  // parity can be used to initialise the checksum directly.

  crc32(x, parity, 1);
  return (x & 1);
}

#pragma unsafe arrays
static int add_to_buffer(unsigned data, unsigned buffer[], int buffer_size, int &buffer_index)
{
  if(buffer_index + 1>= buffer_size)
  {
    return RS485_BUFFER_STATE_OVERRUN;
  }
  else
  {
    buffer[buffer_index] = data;
    buffer_index ++;
    return RS485_BUFFER_STATE_OK;
  }
}

void rs485_run(chanend c_control, chanend c_data, rs485_interface_t &rs485_if, rs485_config_t &rs485_config)
{
  rs485_state_t state;
  int t, data_valid;
  unsigned c, level_test, u;

  unsigned int data = 0;
  timer tim;
  int timeout, timer_enabled = 0;
  int buffer_index;

  unsigned clocks = XS1_TIMER_HZ / rs485_config.baud_rate;
  int dt2 = (clocks * 3)>>1;
  int dt = clocks;

  unsigned buffer[RS485_BUF_SIZE];
  buffer_index = 0;
  state = RS485_STATE_SETUP;

  buffer_index = 0;
  rs485_if.p_dir <: 0;
  state = RS485_STATE_RX_IDLE;
  while(1)
  {
    select
    {
      case rs485_if.p_data when pinseq(0) :> int _ @ t:
        // receive started
	state = RS485_STATE_RX;
	// set/reset packet timer
	tim :> timeout;
        timeout += (clocks * (rs485_config.data_bits + rs485_config.stop_bits + 1)) * rs485_config.data_timeout;
	timer_enabled = 1;

	t += dt2;
	// receive data bits
        for(int i = 0; i < rs485_config.data_bits; i++)
        {
          rs485_if.p_data @ t :> >> data;
	  t += dt;
	}
        data >>= 32 - rs485_config.data_bits;
	// receive parity
        if(rs485_config.parity != RS485_PARITY_NONE)
	{
	  unsigned parity_bit;

          rs485_if.p_data @ t :> parity_bit;
	  t += dt;
          data_valid = parity_bit == parity32(data, rs485_config.parity);
        }
        else
        {
	  data_valid = 1;
	}
        // receive stop bits
        for(int i = 0; i < rs485_config.stop_bits; i++)
        {
          rs485_if.p_data @ t :> level_test;
	  t += dt;
	  if(level_test != 1)
	  {
	    data_valid = 0;
	  }
	}

	if(data_valid)
	{
	  // add data to buffer
          if(add_to_buffer(data, buffer, RS485_BUF_SIZE,buffer_index) == RS485_BUFFER_STATE_OK)
	  {
	    state = RS485_STATE_RX;
          }
          else
          {
	    state = RS485_STATE_RX_ERROR;
	    //handle error
	  }
        }
        else
        {
	  // data valid error
	  state = RS485_STATE_RX_ERROR;
	  // handle error
	}
	break;

        case c_control :> c:
	  switch(c)
	  {
	    case RS485_CMD_SET_BAUD :
	      if(state != RS485_STATE_RX && state != RS485_STATE_TX)
	      {
                c_control :> rs485_config.baud_rate;
                clocks = XS1_TIMER_HZ / rs485_config.baud_rate;
		dt2 = (clocks * 3)>>1;
		dt = clocks;
                c_control <: rs485_config.baud_rate;
              }
              else
              {
                c_control :> u;
                c_control <: 0;
              }
	      break;

	    case RS485_CMD_SET_BITS :
	      if(state != RS485_STATE_RX && state != RS485_STATE_TX)
	      {
                c_control :> rs485_config.data_bits;
                c_control <: rs485_config.data_bits;
              }
              else
              {
                c_control :> u;
                c_control <: 0;
	      }
	      break;

	    case RS485_CMD_SET_PARITY :
	      if(state != RS485_STATE_RX && state != RS485_STATE_TX)
	      {
                c_control :> rs485_config.parity;
                c_control <: rs485_config.parity;
              }
              else
              {
                c_control :> u;
                c_control <: 0;
              }
	      break;

	    case RS485_CMD_SET_STOP_BITS :
	      if(state != RS485_STATE_RX && state != RS485_STATE_TX)
	      {
                c_control :> rs485_config.stop_bits;
                c_control <: rs485_config.stop_bits;
              }
              else
              {
                c_control :> u;
                c_control <: 0;
              }
	      break;

            case RS485_CMD_SEND_BYTE :
	      if(state != RS485_STATE_RX && state != RS485_STATE_TX)
	      {
	        unsigned char b, original_byte;
                c_control :> b;
		original_byte = b;
		// send a byte
		state = RS485_STATE_TX;
		// set the tranciever to TX direction
                rs485_if.p_dir <: 1 << rs485_config.dir_bit;
                rs485_if.p_data <: 1 @ t;
		t += dt;
                rs485_if.p_data @ t <: 0;
		t += dt;
                for(int i = 0; i < rs485_config.data_bits; i++)
                {
                  rs485_if.p_data @ t <: >> b;
		  t += dt;
		}
		//parity
                if(rs485_config.parity != RS485_PARITY_NONE)
		{
                  rs485_if.p_data @ t <: parity32(original_byte, rs485_config.parity);
		  t += dt;
		}
		//stop bits
                for(int i=0; i < rs485_config.stop_bits; i++)
		{
                  rs485_if.p_data @ t <: 1;
		  t += dt;
		}
                rs485_if.p_dir @ t <: 0;
                c_control <: 1;
                rs485_if.p_data :> void;
		state = RS485_STATE_RX_IDLE;
              }
              else
              {
                c_control :> u;
                c_control <: 0;
	      }
	      break;

	    case RS485_CMD_SEND_PACKET:
	      if(state != RS485_STATE_RX && state != RS485_STATE_TX)
	      {
		unsigned len, b, original_byte;
                c_control :> len;
		state = RS485_STATE_TX;
		// set the tranciever to TX direction
                rs485_if.p_dir <: 1 << rs485_config.dir_bit;
		// TX ready
                rs485_if.p_data <: 1 @ t;
		t += dt;
		for(int i=0; i<len; i++)
		{
                  c_control :> b;
		  original_byte = b;
                  rs485_if.p_data @ t <: 0;
		  t += dt;
                  for(int j = 0; j < rs485_config.data_bits; j++)
                  {
                    rs485_if.p_data @ t <: >> b;
		    t += dt;
		  }

		  //parity
                  if(rs485_config.parity != RS485_PARITY_NONE)
		  {
                    rs485_if.p_data @ t <: parity32(original_byte, rs485_config.parity);
		    t += dt;
		  }
		  //stop bits
                  for(int i=0; i < rs485_config.stop_bits; i++)
		  {
                    rs485_if.p_data @ t <: 1;
		    t += dt;
		  }
		}
                rs485_if.p_dir @ t <: 0;
                c_control <: len;
                rs485_if.p_data :> void;
		state = RS485_STATE_RX_IDLE;
	      }
	      break;

	    case RS485_CMD_GET_STATUS :
              c_control <: state;
	      break;
	  }
          break;

	case timer_enabled => tim when timerafter(timeout) :> void :
	  timer_enabled = 0;
	  state = RS485_STATE_RX_DONE;
	  // send buffer
          c_data <: buffer_index;
	  for(int i=0; i<buffer_index; i++)
	  {
            c_data <:(unsigned char) buffer[i];
	  }
	  buffer_index = 0;
	  state = RS485_STATE_RX_IDLE;
	  break;
      }
    }
}

