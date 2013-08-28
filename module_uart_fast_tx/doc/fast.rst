Simple UART
===========

The intention of this module is to implement high speed uart, at the expense of threads and 1-bit ports. Other modules provide lower-speed uarts
that are thread-efficient, or that may use fewer 1-bit ports. This module will support a 10 Mbaud rate with 100 MIPS threads, and correspondingly less
with lower MIPS per thread.


Hardware Platforms
++++++++++++++++++

This UART is supported by all the hardware platforms from XMOS having suitable IO such as XC-1,XC-1A,XC-2,XK-1,etc and can be run on any XS1 series devices.

The example is prepared to run on the L16 sliceKIT but can be easily modified for other boards. However note that a 500 MHz core clock is expected so when running on G4 devices
the baud rate should be reduced until it works, which can be done by altering the last "clocks" argument to the call to uart_tx_fast and uart_rx_fast in app_uart_fast/src/main.xc.

Programming Guide
+++++++++++++++++

API
+++

.. doxygenfunction:: uart_tx_fast

Example programs
++++++++++++++++

Declare ports (and clock blocks if you do not want to run the ports of the
reference clock):

.. literalinclude:: app_uart_fast/src/main.xc
   :start-after: //:: Port declarations
   :end-before: //::

A function that produces data (just bytes 0..255 in this example)

.. literalinclude:: app_uart_fast/src/main.xc
   :start-after: //:: Producer function
   :end-before: //::

A function that consumes data 

.. literalinclude:: app_uart_fast/src/main.xc
   :start-after: //:: Consumer function
   :end-before: //::

And a main par that starts the threads:

.. literalinclude:: app_uart_fast/src/main.xc
   :start-after: //:: Main program
   :end-before: //::

