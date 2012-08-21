Programming Guide
==================

This section discusses the programming aspects of the UART Receive component and typical implementation and usage of the API.

Structure
~~~~~~~~~~

This is an overview of the key header files that are required, as well as the thread structure and information regarding the requirements for the component.

Source Code
++++++++++++

All of the files required for operation are located in the ``module_uart_rx`` directory. The files that are need to be included for use of this component in an application are:

.. list-table::
    :header-rows: 1
    
    * - File
      - Description
    * - `'uart_rx.h``
      - Header file for Uart receive module and API interfaces.
    
Programmers guide to module_uart_receive
--------------------------------------

This module implements uart receive, and can be instantiated with
different functions.

This module comprises many functions that implement UART data receive.
