module_fast_uart
================

The intention of this module is to implement high speed uart, at the
expense of threads and 1-bit ports. Other modules provide lower-speed uarts
that are thread-efficient, or that may use fewer 1-bit ports. This module
is designed to be used with 62.5 MIPS threads and supports 10 MBit UART TX
and RX.

Note: the compiler inserts a spurious ZEXT and SETC in two places which makes
10 Mbit just a tiny bit tight at 62.5 MIPS.

API
---

.. doxygenfunction:: uart_rx

.. doxygenfunction:: uart_tx

Example program
---------------

Declare ports (and clock blocks if you do not want to run the ports of the
reference clock):

.. literalinclude:: app_uart_fast/src/main.xc
  :start-after: //:: Port declarations
  :end-before: //::

A function that produces data (just bytes 0..255 in this example)
.. literalinclude:: app_uart_fast/src/main.xc
  :start-after: //:: Producer function
  :end-before: //::

A function that consumes data (and in this example throws it away)
.. literalinclude:: app_uart_fast/src/main.xc
  :start-after: //:: Consumer function
  :end-before: //::

And a main par that starts the threads:
.. literalinclude:: app_uart_fast/src/main.xc
  :start-after: //:: Main program
  :end-before: //::

