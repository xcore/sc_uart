#include <xs1.h>
#include "uart_rx.h"
#include "uart_tx.h"
#include <print.h>
#include <platform.h>

//:: Port declarations
clock refClk = XS1_CLKBLK_REF;

in port rx = XS1_PORT_1A;
out port tx = XS1_PORT_1B;
//::

//:: Producer function
void produce(streaming chanend c) {
    for(int i = 0; i < 256; i++) {
        c <: (unsigned char) i;
    }
}
//::

//:: Consumer function
void consume(streaming chanend c) {
    unsigned char buf[256];
    unsigned char foo;
    for(int i = 0; i < 200; i++) {
      c :> buf[i];
    }
    for(int i = 0; i < 200; i++) {
      printhexln(buf[i]);
    
    }
}
//::

static inline x() {
    set_thread_fast_mode_on();
}

burn() {
    x();
    while(1);
}

#ifdef EXAMPLE
//:: Main program
int main(void) {
    streaming chan c, d;
    configure_out_port_no_ready(tx, refClk, 1);
    configure_in_port_no_ready(rx, refClk);
    clearbuf(rx);
    par {
        produce(d);
        consume(c);
        uart_tx_fast(tx, d, 100);
        uart_rx_fast(rx, c, 100);
    }
}
//::

#else

//:: Main program
int main(void) {
    streaming chan c, d;
    configure_out_port_no_ready(tx, refClk, 1);
    configure_in_port_no_ready(rx, refClk);
    clearbuf(rx);
    par {
        {x(); produce(d);}
        {x(); consume(c);}
        {x(); uart_tx_fast(tx, d, 10);}
        {x(); uart_rx_fast(rx, c, 10);}
        burn();
        //burn();
        //burn();
        //burn();
    }
    return 0;
}
//::
#endif
