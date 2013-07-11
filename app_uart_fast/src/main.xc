#include <print.h>
#include <platform.h>
#include "uart_rx.h"
#include "uart_tx.h"

#define TEST_LENGTH 32  //number of characters to send/receive in test. Max 256.
#define BIT_PERIOD 10   //bit period in  clock ticks. CLKBLK_REF is 100MHz here
					    //so 10 x 10ns = 100ns per bit period -> 10MHz baudrate
#define DEMO_TILE 0		//xCore tile to run the demo on

//:: Port and clock  declarations
on tile[DEMO_TILE]: in port p_rx = XS1_PORT_1E;			//XD12
on tile[DEMO_TILE]: out port p_tx = XS1_PORT_1F;		//XD13
on tile[DEMO_TILE]: const clock refClk = XS1_CLKBLK_REF; //Use 100MHz reference clock
//::

//:: Producer function
void produce(streaming chanend c) {
  timer t;
  int start_time, end_time;

  t :> start_time;
  for(unsigned int i = 0; i < TEST_LENGTH; i++) {
    c <: (unsigned char) i; //send byte to uart tx
  }
  t :> end_time;
  printstr("Sent ");
  printint(TEST_LENGTH);
  printstr(" characters in ");
  printint((end_time-start_time) / 100);
  printstrln(" microseconds.");
}
//::

//:: Consumer function
void consume(streaming chanend c) {
  unsigned char buf[TEST_LENGTH];
  int test_pass = 1;

  //First receive characters (no time to print them now)
  for(int i = 0; i < TEST_LENGTH; i++) {
    c :> buf[i]; //receive byte from uart tx
  }

  //Now check we have received an incrementing array of bytes
  for(int i = 0; i < TEST_LENGTH; i++) {
    if (buf[i] != i) {
      printstr("Test failed. Value in array index ");
      printint(i);
      printstr(" incorrect. Received ");
      printintln(buf[i]);
      test_pass = 0;
    }
  }
  if (test_pass) printstrln("Loopback test passed successfully.");
}
//::


//:: Main program
int main(void) {
	//Declare channels to connect UART to producer/consumer. Streaming used for max speed
	streaming chan c_producer_to_tx, c_rx_to_consumer;

    //Configure ports to be clocked from specified clock source and initialis
    par {
    	on tile[DEMO_TILE]: {
    						uart_tx_fast_init(p_tx, refClk);
    						uart_tx_fast(p_tx, c_producer_to_tx, BIT_PERIOD);
    						}
    	on tile[DEMO_TILE]: {
    						uart_rx_fast_init(p_rx, refClk);
    						uart_rx_fast(p_rx, c_rx_to_consumer, BIT_PERIOD);
    						}
    	on tile[DEMO_TILE]: produce(c_producer_to_tx);
    	on tile[DEMO_TILE]: consume(c_rx_to_consumer);
    }
return 0;
}
//::


