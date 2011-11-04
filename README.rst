XCORE.com UART SOFTWARE COMPONENT
.................................

:Stable release:   unreleased

:Status (module_uart):  Design Ready
:Status: (module_uart_fast): Example

:Maintainer:  Dan Wilkinson (github: djpwilk)


Key Features
============

module_uart_rx/tx
-----------------

   * Designed to be composed with other application functions in the same thread. Note that this is a manual process.
   * RX and TX in separate threads
   * Baud Rates up to 115.2K
   * Even, Odd or No Parity
   * 5,6,7 or 8 bits per byte
   * 1 or 2 stop bits
   * configurable buffer sizes  
   * RX and TX are defined as functions which each run in their own virtual par which does not terminate, and have a  
     simple client API. 
   * A simulator plugin testbench and demo applictions are included.

module_uart_fast_rx/tx
----------------------

   * Needs thread for transmission and another for reception
   * Fixed to 8 bits, single start bit, no parity, single stop bit. 
   * All of these parameters can be changed by editing the module. 
   * The baud rate is parameterisable, but has to be a whole division of 100 MHz.
   * Basic testing to 10 MBaud has been done

Known Issues
============

none

Required Modules
=================

   * xcommon git\@github.com:xmos/xcommon.git


Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the manitainer for this line.
