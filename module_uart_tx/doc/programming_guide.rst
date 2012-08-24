Programming Guide
==================

This section discusses the programming aspects of the UART Transmit component and typical implementation and usage of the API.

Structure
---------

All of the files required for operation are located in the ``module_uart_tx`` directory. Applications using this module should include the `'uart_tx.h`` header file from the src directory.
    
Programmers guide to module_uart_receive
----------------------------------------

This module implements uart receive, and can be instantiated with
different functions.

This module comprises many functions that implement UART data transmit.

API
===

.. doxygenfunction:: uart_tx

.. doxygenfunction:: uart_tx_send_byte

.. doxygenfunction:: uart_tx_set_baud_rate

.. doxygenfunction:: uart_tx_set_parity

.. doxygenfunction:: uart_tx_set_stop_bits

.. doxygenfunction:: uart_tx_set_bits_per_byte
