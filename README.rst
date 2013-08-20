XCORE.com UART SOFTWARE COMPONENT
.................................

:Latest release: 2.3.1beta2
:Maintainer: djpwilk
:Description: Inline libraries for various simple uart implementations


:Status: (module_uart):  Design Ready
:Status: (module_uart_fast): Example

:Maintainer:  Dan Wilkinson (github: djpwilk)

Key Features
============

Generic UART
------------

module_uart_rx
module_uart_tx

   * Inline library that assumes RX and TX in separate threads
   * Baud Rates up to 115.2K, any combination of bits per byte, parity, stop bits
   * configurable buffer sizes  
   * An XSIM testbench and demo appliction for the XK-1A is included.

Simple/Fast UART
----------------

module_uart_fast_rx
module_uart_fast_tx

   * Needs thread for transmission and another for reception
   * Fixed to 8 bits per byte, single start bit, no parity, single stop bit. 
   * All of these parameters can be changed by editing the module. 
   * The baud rate is parameterisable, but has to be a whole division of 100 MHz.
   * 10 MBaud is achievable in a 100 MIPS thread
   * Includes an XK-1A demo application

Documentation
=============

See http://github.xcore.com/sc_uart.

Known Issues
============

none

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the manitainer for this line.

Required software (dependencies)
================================

  * None

