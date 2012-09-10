Generic UART
============

This UART has two modules, one for RX and one for TX each of which uses one thread and is connected via channel to another thread using the UART Client API . 

The thread for the UART TX component receives data from the client via a buffer (configurable between 1 and 64 bytes). A full buffer will block the client.
  
The thread for the UART RX component receives data from external into the RX buffer (configurable between 1 and 64 bytes) which is read by the client using channel. An empty RX buffer will block the client.

Resource Requirements
---------------------

A single generic uart consisting of module_uart_rx and module_uart_tx will consumer the following resources:

 +-----------------+---------+
 | Resource        | Usage   |
 +=================+=========+
 | Code  Memory    | 2110    |
 +-----------------+---------+
 | Ports           | 2 x 1b  |
 +-----------------+---------+
 | ChannelEnds     | 2       |
 +-----------------+---------+

Evaluation Platforms
--------------------

.. _sec_hardware_platforms:

Recommended Hardware
++++++++++++++++++++

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-GPIO plus XA-SK-ATAG2 (Slicekit XTAG adaptor) plus XTAG2 (debug adaptor), OR
   * XK-SK-L2-ST (Slicekit Starter Kit, containing all of the above).

Demonstration Application
+++++++++++++++++++++++++

Example usage of this module can be found within the XSoftIP suite as follows:

   * Package: sw_gpio_examples
   * Application: app_slicekit_com_demo

   * Package: sc_uart
   * Application: app_uart_back2back

API and Programming Guide
-------------------------

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


TX API
++++++

The UART TX component is started using the uart_tx() function, which causes the TX server (called "_impl" in the code) to run in a while(1) loop until it receives and instruction to shut down via the channel from the client. Additionally a set of client functions are provided to transmit a byte and to alter the baud rate, parity, bits per byte and stop bit settings. Any such action except transmitting a byte causes the TX server to terminate and then be restarted with the new settings. Any data in the TX buffer is preserved and then sent with the new settings.

.. doxygenfunction:: uart_tx
.. doxygenfunction:: uart_tx_send_byte
.. doxygenfunction:: uart_tx_set_baud_rate
.. doxygenfunction:: uart_tx_set_parity
.. doxygenfunction:: uart_tx_set_stop_bits
.. doxygenfunction:: uart_tx_set_bits_per_byte

RX API
++++++

The UART RX component is started using the uart_tx() function, which causes the TX server (called "_impl" in the code) to run in a while(1) loop until it receives and instruction to shut down via the channel from the client. Additionally a set of client functions are provided to fetch a byte from teh recieve buffer and to alter the baud rate, parity, bits per byte and stop bit settings. Any such action except transmitting a byte causes the RX server to terminate, the receive buffer emptied, and then restarted immediately with the new settings. 

.. doxygenfunction:: uart_rx
.. doxygenfunction:: uart_rx_get_byte
.. doxygenfunction:: uart_rx_get_byte_byref
.. doxygenfunction:: uart_rx_set_baud_rate
.. doxygenfunction:: uart_rx_set_parity
.. doxygenfunction:: uart_rx_set_stop_bits
.. doxygenfunction:: uart_rx_set_bits_per_byte

Example Applications
--------------------

GPIO Slice Examples
+++++++++++++++++++

This uart is used in the app_slicekit_com demo from the sw_gpio_exampels package. FIXME

Basic Loopback Example
++++++++++++++++++++++

These modules are also demonstrated wired back to back using app_uart_back2back. To prepare the Slicekit core board to run this app connect wires between the 0.1" testpoints on the Triangle slot (or solder suitable headers on as shown in the picture below), such that ports 1A and 1E are connected. The headers corresponding to these ports are marked D0 and D12 respectively. 

The app can then be built and run. 

It will send the full set of characters from the UART TX, receive them on UART RX and then print them out in batches of 10 characters.
  
