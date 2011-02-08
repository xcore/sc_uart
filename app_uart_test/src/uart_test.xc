#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <stdlib.h>
#include <stdio.h>
#include "uart_rx.h"

#include "uart_rx_impl.h"
#include "uart_tx.h"
//#include "header.h"
#include <stdio.h>
#include "UART_test.h"
#if 0
#define BIT_RATE_0 57600

#endif
#define BIT_RATE_MAX 115200
#define BITTIME(x) (100000000 / (x))

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

unsigned baud_rate = BIT_RATE;
//struct STCTX readfile(void);
void fwrite_XMOS();
unsigned char data[] = { 0x11, 0x00, 0x2c, 0x09};

#ifdef BUFFER_SIZE_64_OFF
#define NUM 1
#else
#define NUM 64
#endif

#define TEST_ASSERT(x)\
do {\
  if (!(x)) {\
    printstr("Fail on line ");\
    printuintln(__LINE__);\
    _Exit(1);\
  }\
} while(0)

unsigned int bitsperbyte ;
unsigned int set_parity = 0;
static int checkNoRxData(chanend uartRX, uart_rx_client_state &state, unsigned timeout)
{
  timer t;
  unsigned time;
  unsigned char byte;
  t :> time;
  select {
  case t when timerafter(time + timeout) :> void:
    return 1;
  case uart_rx_get_byte_byref(uartRX, state, byte):
    return 0;
  }
}

void testUART(chanend uartTX, chanend uartRX)
{

	int reminder;
	int result =0;
	int quatient = 99;
	unsigned ui32stopbit = 1;
	unsigned ui32bitsperbyte = 8;
//	struct STCTX stcontext;


 uart_rx_client_state rxState;
  unsigned x;
  uart_rx_init(uartRX, rxState);
  // Configure RX, TX
  uart_rx_set_baud_rate(uartRX, rxState, baud_rate);
  uart_tx_set_baud_rate(uartTX, baud_rate);

 // printf("baud rate = %d\n",baud_rate);
  uart_tx_send_byte(uartTX, 0x0A);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x0A);
  uart_tx_send_byte(uartTX, 0x04);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x04);


  //stcontext  = readfile();

  //ui32stopbit = stcontext.ui32stopbit;
  //ui32bitsperbyte = stcontext.ui32bitsperbyte;

#ifdef ENABLE_EVENT_UART_RX_GET_BYTE
  // Check we can event on uart_rx_get_byte.
  printf("Check we can event on uart_rx_get_byte\n");
  {
    timer t;
    unsigned time;
    unsigned char byte;
    t :> time;
    uart_tx_send_byte(uartTX, 173);
    select {
    case t when timerafter(time + BITTIME(baud_rate) * 20) :> void:
      // Shouldn't get here.
      TEST_ASSERT(0);
      break;
    case uart_rx_get_byte_byref(uartRX, rxState, byte):
      TEST_ASSERT(byte == 173);
      break;
    }
  }

#endif


#ifdef RUNTIME_PARAMETER_CHANGE
  // Reconfigure
  //printf("Reconfiguring UART...\n");
  uart_rx_set_baud_rate(uartRX, rxState, BIT_RATE_MAX);
  uart_rx_set_stop_bits(uartRX, rxState, 10);
  uart_rx_set_bits_per_byte(uartRX, rxState, ui32bitsperbyte);//7
  uart_tx_set_baud_rate(uartTX, BIT_RATE_MAX);
  uart_tx_set_stop_bits(uartTX, 10);
  uart_tx_set_bits_per_byte(uartTX, ui32bitsperbyte);//7


  printf("\n %d", 115200);
  printf("\t%d", ui32bitsperbyte);


  uart_tx_send_byte(uartTX, 0x12);
  uart_tx_send_byte(uartTX, 0x5a);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x12);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x5a);

  //printf("checking for parity ..\n");
  printf("\t\t%d",1);
  // Check parity
  uart_rx_set_parity(uartRX, rxState, UART_RX_PARITY_ODD);
  uart_rx_set_stop_bits(uartRX, rxState, ui32stopbit);//1
  uart_rx_set_bits_per_byte(uartRX, rxState, ui32bitsperbyte);
  uart_tx_set_parity(uartTX, UART_TX_PARITY_ODD);
  uart_tx_set_stop_bits(uartTX, ui32stopbit);// 1
  uart_tx_set_bits_per_byte(uartTX, ui32bitsperbyte);

  printf("\t\t %d",ui32stopbit);

  uart_tx_send_byte(uartTX, 0x12);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0x12);
  uart_tx_send_byte(uartTX, 0xa4);
  TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == 0xa4);
#endif
/* **********************************************************************************
   *     Check buffering
   *
 ***********************************************************************************/

#ifdef CHECK_BUFFERING
  {
    timer t;
    unsigned time;
  /*  unsigned char data[] = { 0xf9, 0x28, 0x2c, 0x09,0x55,0xAA,0xFF,0x00,
    		0xf9, 0x28, 0x2c, 0x09,0x55,0xAA,0xFF,0x00,
    		0xf9, 0x28, 0x2c, 0x09,0x55,0xAA,0xFF,0x00,
    		0xf9, 0x28, 0x2c, 0x09,0x55,0xAA,0xFF,0x00,
    		0xf9, 0x28, 0x2c, 0x09,0x55,0xAA,0xFF,0x00};*/


    for (unsigned i = 0; i < ARRAY_SIZE(data); i++) {
      uart_tx_send_byte(uartTX, data[i]);
      //data[0]++ ;

    }
    t :> time;
    t when timerafter(time + BITTIME(baud_rate) * 11 * 4) :> void;
    for (unsigned i = 0; i < ARRAY_SIZE(data); i++) {
      TEST_ASSERT(uart_rx_get_byte(uartRX, rxState) == data[i]);
      //printf("%x\n",data[0]);
    //  data[1]++ ;
    }
  }
  printf("\nbuffer size\t\t\tbytes transmitted\n ");
  //printf("%d\t\t%d",NUM,ARRAY_SIZE(data));
  printf("%d\t\t%d",64,4);
#endif
/* **********************************************************************************
 *  Check data is discarded on incorrect parity
 *
 ***********************************************************************************/
#ifdef TEST_PARITY
  uart_rx_set_parity(uartRX, rxState, UART_RX_PARITY_ODD);
  uart_tx_set_parity(uartTX, UART_TX_PARITY_EVEN);
  uart_tx_send_byte(uartTX, 0x55);
  TEST_ASSERT(checkNoRxData(uartRX, rxState, BITTIME(baud_rate) * 500));
  uart_rx_set_parity(uartRX, rxState, UART_RX_PARITY_EVEN); //UART_RX_PARITY_EVEN
  uart_tx_set_parity(uartTX, UART_TX_PARITY_ODD);
  uart_tx_send_byte(uartTX, 0x55);
  TEST_ASSERT(checkNoRxData(uartRX, rxState, BITTIME(baud_rate) * 500));
#endif
/**************************************************************************************
 *
 */
  printstrln("Pass");
  _Exit(0);
}

buffered in port:1 rx = on stdcore[0] : XS1_PORT_1A;
out port tx = on stdcore[0] : XS1_PORT_1B;

#pragma unsafe arrays
int main() { //int main(int argc, char *argv[])
  chan chanTX, chanRX;



  par {
    on stdcore[0] : {
      unsigned char tx_buffer[NUM];
      unsigned char rx_buffer[NUM];
      tx <: 1;
      par {
        uart_rx(rx, rx_buffer, ARRAY_SIZE(rx_buffer), baud_rate, BITS_PER_BYTE, SET_PARITY, STOP_BIT, chanRX);
        uart_tx(tx, tx_buffer, ARRAY_SIZE(tx_buffer), baud_rate, BITS_PER_BYTE, SET_PARITY, STOP_BIT, chanTX);
      }
    }
    on stdcore[0] : {
      testUART(chanTX, chanRX);
    }
  }
  return 0;
}
