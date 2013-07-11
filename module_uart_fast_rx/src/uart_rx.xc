// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <xclib.h>

void uart_rx_fast_init(in port p, const clock clkblk){
    //set port into clocked mode
	configure_in_port_no_ready(p, clkblk);
	//clear the receive buffer
    clearbuf(p);
}

void uart_rx_fast(in port pIn, streaming chanend cOut, int clocks) {
    int dt2 = (clocks * 3)>>1; //one and a half bit times
    int dt = clocks;
    int t;
    unsigned int data = 0;
    while (1) {
        pIn when pinseq(0) :> int _ @ t; //wait until falling edge of start bit
        t += dt2;
#pragma loop unroll(8)
        for(int i = 0; i < 8; i++) {
            pIn @ t :> >> data; //sample value when port timer = t
            					//inlcudes post right shift
            t += dt;
        }
        data >>= 24;			//shift into MSB
        cOut <: (unsigned char) data; //send to client
        data = 0;
    }
}

