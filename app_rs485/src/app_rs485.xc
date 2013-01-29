// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <print.h>
#include <xscope.h>
#include <platform.h>

#include "rs485.h"

#define DIR_BIT 0
#define BAUD 1000000
#define DATA 8
#define STOP 2
#define PARITY RS485_PARITY_NONE
#define TIMEOUT 200
#define BUF_SIZE 128
//:: Port declarations
on tile[0]: clock refClk = XS1_CLKBLK_REF;
on tile[0]: port pData = XS1_PORT_1J;
on tile[0]: out port pDir = XS1_PORT_4E;


void xscope_user_init(void)
{
  xscope_register(0, 0, "", 0, "");
  // Enable XScope printing
  xscope_config_io(XSCOPE_IO_BASIC);
}

void consume(chanend d, chanend c) {
    unsigned char buf[BUF_SIZE];
    unsigned len;
    unsigned result;

    while(1)
    {
		d :> len;
		for(int i = 0; i < len; i++) {
		  d :> buf[i];
		}
		result = rs485_send_packet(c, buf, len);
		if(!result)
		{
			printstr("TX error\n");
		}
    }
}


int main(void){
	chan c,d;

	par{
		on tile[0]:{consume(d, c);}
		on tile[0]:{rs485_run(pData, pDir, DIR_BIT, c, d, BAUD, DATA, STOP, PARITY, TIMEOUT);}
//		on tile[0]:{ set_thread_fast_mode_on(); while (1); }	// Burn MIPS
//		on tile[0]:{ set_thread_fast_mode_on(); while (1); }	// Burn MIPS
//		on tile[0]:{ set_thread_fast_mode_on(); while (1); }	// Burn MIPS
//		on tile[0]:{ set_thread_fast_mode_on(); while (1); }	// Burn MIPS
//		on tile[0]:{ set_thread_fast_mode_on(); while (1); }	// Burn MIPS
//		on tile[0]:{ set_thread_fast_mode_on(); while (1); }	// Burn MIPS
	}
	return 0;
}


