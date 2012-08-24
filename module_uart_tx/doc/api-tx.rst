Programming Guide
==================

This UART has two modules, one for RX and one for TX each of which uses one thread and is connected via channel to another thread using the UART Client API . 

The thread for the UART TX component receives data from the client via a buffer (configurable between 1 and 64 bytes). A full buffer will block the client.
  
The thread for the UART RX component receives data from external into the RX buffer (configurable between 1 and 64 bytes) which is read by the client using channel. An empty RX buffer will block the client.


Structure
---------

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

Usage  
-----

The UART TX component is started using the uart_tx() function, which causes the TX server (called "_impl" in the code) to run in a while(1) loop until it receives and instruction to shut down via the channel from the client. 

Additionally a set of client functions, found in uart_tx.h above, are provided to transmit a byte and to alter the baud rate, parity, bits per byte and stop bit settings. Any such action except transmitting a byte causes the TX server to terminate and then be restarted with the new settings. Any data in the TX buffer is preserved and then sent with the new settings.

API
===

.. doxygenfunction:: uart_tx

.. doxygenfunction:: uart_tx_send_byte

.. doxygenfunction:: uart_tx_set_baud_rate

.. doxygenfunction:: uart_tx_set_parity

.. doxygenfunction:: uart_tx_set_stop_bits

.. doxygenfunction:: uart_tx_set_bits_per_byte
