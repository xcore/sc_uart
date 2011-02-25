Overview
========

The UART (Universal Asynchronous Receiver and Transmitter ) has following two components which can be used independantly. Each Component has one thread which is connected via channel to the Client API . 

UART TX (module_uart_tx)
------------------------

UART TX component for transmitting data serially to 1 single bit port with specified configurations. This can be used as stand alone package as module_uart_tx.1v0

 
UART RX (module_uart_rx)
------------------------

UART RX component for receiving from 1 single bit port data serially as per the specified configurations. This can be used as stand alone package as module_uart_rx.1v0 

Dependencies
------------

module_xmos_common, the common build framework for applications using xmos modules is required to build this module.


Hardware Platform
=================

The PWM components are supported by all the hardware platforms from XMOS having suitable IO such as XC-1,XC-1A,XC-2,XK-1,etc and can be run on any XS1-L or XS1-G series devices.
  
The following modules are provided in this package, these can be
used in your applications:

Demo applications
-----------------

The UART functionality is demonstrated using following demo applications. The applications run on XC-1 board and using 10.4.2 or later versions of the tools.

app_uart_test
+++++++++++++
 
It will send data out via the UART TX component using single bit port  and receive via UART RX component from another single bit port. It will check that the data matches. It requires hardware loopback between the ports.
  
app_uart_back2back
++++++++++++++++++

It will receive via the RX component and echo via TX component.


System Description
==================

The UART uses one buffer each for UART TX & UART RX component which are configurable from 1 to 64 bytes. Each of the component runs within single thread and are linked to Client API using channel. 

The thread for the UART TX component receives data from the Client & transmits that through 1 single bit port to external device. The bytes will get buffered and queued to get transmitted and in the case of TX buffer being full , the client gets blocked for sending further data.
  
The thread for the UART RX component receives data from external device via 1 single bit port into the RX buffer which is read by the client using channel. In case data is not ready , client will get blocked for reception until data is available at RX buffer.


Programming Guide
=================

 The UART (Universal Asynchronous Receiver and Transmitter) module is structured as follows:


UART TX component
-----------------    

   For the UART TX component the following API runs in virtual Par which does not terminate.

void uart_tx(out port txd, unsigned char buffer[], unsigned buffer_size,
         unsigned baud_rate, unsigned bits, enum uart_tx_parity parity,
         unsigned stop_bits, chanend c)

The UART TX component has following client function calls :
  
void uart_tx_send_byte(chanend c, unsigned char byte)

	This function sends single byte data to be transmitted over serial link from Client to UART TX component. This byte will be buffered & queued to send. In case of buffer full , it will not return until there is space in the buffer. This function is not selectable.void uart_tx_set_baud_rate(chanend c, unsigned baud_rate)

void uart_tx_set_parity(chanend c, enum uart_tx_parity parity)

void uart_tx_set_stop_bits(chanend c, unsigned stop_bits)

void uart_tx_set_bits_per_byte(chanend c, unsigned bits)

    These functions will pass specified configuration parameter such as baud rate , parity , stop bit and bits per byte from client to UART TX component during execution time. 

UART RX component
-----------------

void uart_rx(in buffered port:1 rxd, unsigned char buffer[],
                unsigned buffer_size, unsigned baud_rate, unsigned bits,
                enum uart_rx_parity parity, unsigned stop_bits,
                chanend c)

   The component is responsible for receiving data from external device & passing it to Client API via channel.

unsigned char uart_rx_get_byte(chanend c, uart_rx_client_state &state)

   This function receives a byte from the UART RX component buffer & gives to Client API. If this is called stand alone & in case of byte is not ready to receive i.e. RX buffer is empty , it will block.   The function is selectable.
 
void uart_rx_set_baud_rate(chanend c, uart_rx_client_state &state, unsigned baud_rate)
void uart_rx_set_parity(chanend c, uart_rx_client_state &state, enum uart_rx_parity parity)

void uart_rx_set_stop_bits(chanend c, uart_rx_client_state &state, unsigned stop_bits)

void uart_rx_set_bits_per_byte(chanend c, uart_rx_client_state &state, unsigned bits)

		These functions will pass specified configuration parameter such as baud rate , parity , stop bit and bits per byte from client to UART RX component during execution time. 

   
	For each of the demo application, a separate .xe (executable ) file will be generated after running  Makefile provided in the parent folder xmos_uart..
 This can be set for the setting the target as xmake clean , xmake all or xmake test. 

    Besides this , each of the demo application has there own Makefile. This will get executed while calling Makefile from the parent folder .


Resource Usage
==============


The following table details the resource usage of each
component of the reference design software.

 +-----------------+------------- -+----------------+
 |   Memory        |  Size(KB)     | percentage(%)  |
 +=================+===============+================+
 | Stack Memory    |     0.5       |    0.18        |
 |                 |               |                |
 +-----------------+---------------+----------------+			
 | Data Memory     |     1.7       |    0.64        |
 +-----------------+---------------+----------------+
 | Program Memory  |    29.8       |   11.39        | 
 +-----------------+---------------+----------------+ 
 | Free(available) |   230.1       |   87.78        |                      
 +-----------------+---------------+----------------+
 
  
 For each configuration , it requires 1 x1-bit port.

Validation
==========
   
      There are some test benches provided for validation of  demo application. The test benches can be run for various combinations of macros for setting different configuration for TX , RX components of UART. 
For running testbench , python script <regression_script_UART.py>. There are following ways to execute different testbench.

 +--------------------------+---------------------------------------------------+----------------------------------------------------------------+
 |   Testbench   	    |  Command   					| Description 	                                                 |
 |		     	    |							|							         |
 +==========================+===================================================+================================================================+
 | 		            |                                         	 	|This test will confirm that buffer size is enough and data from | 
 | check buffering   	    | <script.py> -check_buffering        	 	|TX buffer to RX buffer passes correctly                         |
 +--------------------------+---------------------------------------------------+----------------------------------------------------------------+
 | 		            | <script.py> -runtime_parameter_change   	 	|This test will confirm UART module supports change in parameter |
 | runtime parameter change |							|during runtime such as baud-rate,bits per byte, parity, stopbit |
 +--------------------------+---------------------------------------------------+----------------------------------------------------------------+
 | 		   	    | <script.py> -test_parity   		 	|This test will confirm UART module discards data in case of     |
 | Parity test              |					 		|mismatch in  change in parity                                   |
 +--------------------------+---------------------------------------------------+----------------------------------------------------------------+
 | single test   	    |script.py -buad_rate <baud_rate> -bitsperbyte      |This test will confirm UART module discards data in case of     |
 |                   	    |<bitsperbyte> -parity <parity> -stopbit <stopbit>	|mismatch in  change in parity                                   |
 +--------------------------+---------------------------------------------------+----------------------------------------------------------------+
 |			    |<script.py>				        | This will take all possible combinations of baud-rate,bits     |
 | regression test          |							|per byte,parity and no. of stop bits.it will use testlist.txt   | 
 +--------------------------+---------------------------------------------------+----------------------------------------------------------------+

