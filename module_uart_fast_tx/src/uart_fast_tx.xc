// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>

void uart_tx_fast_init(out port p, const clock clkblk){
    //set to clocked port, with initial value 1 (idle for UART)
    configure_out_port_no_ready(p, clkblk, 1);
}


void uart_tx_fast(out port p, streaming chanend c, int clocks) {
    int t;
    unsigned char b;
    while (1) {
        c :> b;
        p <: 0 @ t; //send start bit and timestamp (grab port timer value)
        t += clocks;
#pragma loop unroll(8)
        for(int i = 0; i < 8; i++) {
            p @ t <: >> b; //timed output with post right shift
            t += clocks;
        }
        p @ t <: 1; //send stop bit
        t += clocks;
        p @ t <: 1; //wait until end of stop bit
    }
}
