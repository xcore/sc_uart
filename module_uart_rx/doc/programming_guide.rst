Programming Guide
==================

The module implements a uart receive server in one logical core, and provides client functions for application code to access the server.

Structure
---------

All of the files required for operation are located in the ``module_uart_rx`` directory. Applications using this module should include the `'uart_rx.h`` header file from the src directory.
   
API
===

.. doxygenstruct:: uart_rx_client_state

.. doxygenfunction:: uart_rx

.. doxygenfunction:: uart_rx_init

.. doxygenfunction:: uart_rx_get_byte

.. doxygenfunction:: uart_rx_set_baud_rate

.. doxygenfunction:: uart_rx_set_parity

.. doxygenfunction:: uart_rx_set_stop_bits

.. doxygenfunction:: uart_rx_set_bits_per_byte
