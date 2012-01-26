// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>

void uart_tx_fast(out port p, streaming chanend c, int clocks) {
    int t;
    unsigned char b;
    while (1) {
        c :> b;
        p <: 0 @ t;
        t += clocks;
#pragma loop unroll(8)
        for(int i = 0; i < 8; i++) {
            p @ t <: >> b;
            t += clocks;
        }
        p @ t <: 1;
        t += clocks;
        p @ t <: 1;
    }
}
