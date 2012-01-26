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
| module_uart_rx/src/uart_rx.h        | Client API header file for Generic UART RX    |
+-------------------------------------+-----------------------------------------------+
| module_uart_rx/src/uart_rx.xc       | Client API implementation for Generic UART RX |
+-------------------------------------+-----------------------------------------------+
| module_uart_rx/src/uart_rx_impl.h   | UART RX Server Header File                    |
+-------------------------------------+-----------------------------------------------+
| module_uart_rx/src/uart_rx_impl.xc  | UART RX Server implementation                 |
+-------------------------------------+-----------------------------------------------+

Required Repositories
+++++++++++++++++++++

* xcommon git\@github.com:xcore/xcommon.git

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


UART RX component Overview
++++++++++++++++++++++++++

The UART RX component is started using the uart_tx() function, which causes the TX server (called "_impl" in the code) to run in a while(1) loop until it receives and instruction to shut down via the channel from the client. Additionally a set of client functions are provided to fetch a byte from teh recieve buffer and to alter the baud rate, parity, bits per byte and stop bit settings. Any such action except transmitting a byte causes the RX server to terminate, the receive buffer emptied, and then restarted immediately with the new settings. 

UART RX API
+++++++++++

.. doxygenfunction:: uart_rx
.. doxygenfunction:: uart_rx_get_byte
.. doxygenfunction:: uart_rx_get_byte_byref
.. doxygenfunction:: uart_rx_set_baud_rate
.. doxygenfunction:: uart_rx_set_parity
.. doxygenfunction:: uart_rx_set_stop_bits
.. doxygenfunction:: uart_rx_set_bits_per_byte

Validation
++++++++++
   
There are some test benches provided for validation of the demo application. The test benches can be run for various combinations of macros for setting different configuration for TX , RX components of UART. 

The testbench is run using a python script: regression_script_UART.py. The test suites are executed as follows:

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

  
Demo applications
-----------------

The UART functionality is demonstrated using following demo applications. The applications run on XC-1 board and using 10.4.2 or later versions of the tools.

app_uart_test
+++++++++++++
 
It will send data out via the UART TX component using single bit port  and receive via UART RX component from another single bit port. It will check that the data matches. It requires hardware loopback between the ports.
  
app_uart_back2back
++++++++++++++++++

It will receive via the RX component and echo via TX component.

