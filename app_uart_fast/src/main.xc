#include <xs1.h>
#include "uart_rx.h"
#include "uart_tx.h"

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
    for(int i = 0; i < 256; i++) {
        c :> unsigned char _;
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
        uart_tx(tx, d, 10);
        uart_rx(rx, c, 10);
    }
    return 0;
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
        {x(); uart_tx(tx, d, 10);}
        {x(); uart_rx(rx, c, 10);}
        burn();
        burn();
        burn();
        burn();
    }
    return 0;
}

#endif
