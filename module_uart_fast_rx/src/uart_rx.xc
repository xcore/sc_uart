// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <xclib.h>

void uart_rx_fast(in port pIn, streaming chanend cOut, int clocks) {
    int dt2 = (clocks * 3)>>1;
    int dt = clocks;
    int t;
    unsigned int data = 0;
    while (1) {
        pIn when pinseq(0) :> int _ @ t;
        t += dt2;
#pragma loop unroll(8)
        for(int i = 0; i < 8; i++) {
            pIn @ t :> >> data;
            t += dt;
        }
        data >>= 24;
        cOut <: (unsigned char) data;
        pIn @ t :> int _;
        data = 0;
    }
}

