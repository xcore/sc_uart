Generic UART
============

This UART has two modules, one for RX and one for TX each of which uses one thread and is connected via channel to another thread using the UART Client API . 

The thread for the UART TX component receives data from the client via a buffer (configurable between 1 and 64 bytes). A full buffer will block the client.
  
The thread for the UART RX component receives data from external into the RX buffer (configurable between 1 and 64 bytes) which is read by the client using channel. An empty RX buffer will block the client.


Hardware Platforms
------------------

This UART is supported by all the hardware platforms from XMOS having suitable IO such as XC-1,XC-1A,XC-2,XK-1,etc and can be run on any XS1-L or XS1-G series devices.


Programming Guide
-----------------

Key Files
+++++++++

+-------------------------------------+-----------------------------------------------+
| File                                | Description                                   |
+-------------------------------------+-----------------------------------------------+
| module_uart_tx/src/uart_tx.h        |Client API header file for Generic UART TX     |
+-------------------------------------+-----------------------------------------------+
| module_uart_tx/src/uart_tx.xc       | Client API implementation for Generic UART TX |
+-------------------------------------+-----------------------------------------------+
| module_uart_tx/src/uart_tx_impl.h   | UART TX Server Header File                    |
+-------------------------------------+-----------------------------------------------+
| module_uart_tx/src/uart_tx_impl.xc  | UART TX Server implementation                 |
+-------------------------------------+-----------------------------------------------+

Required Repositories
+++++++++++++++++++++

* xcommon git\@github.com:xcore/xcommon.git

Resource Usage
--------------

The following table details the resource usage of the component.

 +-----------------+---------+
 | Resource        | Usage   |
 +=================+=========+
 | Code  Memory    | 2110    |
 +-----------------+---------+
 | Ports           | 2 x 1b  |
 +-----------------+---------+
 | ChannelEnds     | 2       |
 +-----------------+---------+

  
Demo Application
-----------------

The UART functionality is demonstrated using the app_uart_back2back. This has been rpepared to run on an XK-1 board, but can easily be ported to other development boards with small modificatiosn to the code. To prepare the XK-1 board to run this app, simply connect a jumper such that ports 1A and 1B are connected (e.g. connect X0D1 and X0D0 pins on the GPIO header). Refer to the XK-1 Hardware Manual for pni positions.

The app can then be built and run. 

It will send the full set of characters from the UART TX, receive them on UART RX and then print them out in batches of 10 characters.

  
app_uart_back2back
++++++++++++++++++

It will receive via the RX component and echo via TX component.

UART TX component Overview
++++++++++++++++++++++++++

The UART TX component is started using the uart_tx() function, which causes the TX server (called "_impl" in the code) to run in a while(1) loop until it receives and instruction to shut down via the channel from the client. Additionally a set of client functions are provided to transmit a byte and to alter the baud rate, parity, bits per byte and stop bit settings. Any such action except transmitting a byte causes the TX server to terminate and then be restarted with the new settings. Any data in the TX buffer is preserved and then sent with the new settings.

UART TX API
+++++++++++

.. doxygenfunction:: uart_tx
.. doxygenfunction:: uart_tx_send_byte
.. doxygenfunction:: uart_tx_set_baud_rate
.. doxygenfunction:: uart_tx_set_parity
.. doxygenfunction:: uart_tx_set_stop_bits
.. doxygenfunction:: uart_tx_set_bits_per_byte


Verification
------------
   
An application app_uart_test is provided to run in XSIM using the Loopback Plugin DLL (see Tools User Guide for details) that validates the various combinations of parity, stop bit, bits-per-byte and baud rate settings. It will send data out via the UART TX component using single bit port and receive via UART RX component from another single bit port. It will check that the data matches.

The testbench is run using a python script: regression_script_UART.py. The test suites are executed as follows (after having built the application with the makefile provided:

 +--------------------------+---------------------------------------------------+----------------------------------------------------------------+
 |   Testbench   	    |  Command   					| Description 	                                                 |
  +==========================+===================================================+===============================================================+
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

The output is dumped to log.txt. This file should be manually removed, if it exists, before re-running.


