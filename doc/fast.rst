Simple UART
===========

The intention of this module is to implement a high speed uart, at the expense of logical cores and 1-bit ports. Other modules provide lower-speed uarts
that are logical core-efficient, or that may use fewer 1-bit ports. This module will support a 10 Mbaud rate with 100 MIPS logical cores, and correspondingly less
with lower MIPS per logical core.


Resource Requirements
---------------------

 +-----------------+---------+
 | Resource        | Usage   |
 +=================+=========+
 | Code  Memory    | 2110    |
 +-----------------+---------+
 | Ports           | 2 x 1b  |
 +-----------------+---------+
 | ChannelEnds     | 2       |
 +-----------------+---------+
 | Logical Cores   | 2       |
 +-----------------+---------+

Evaluation Platforms
--------------------

Recommended Hardware
++++++++++++++++++++

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-XTAG2 (Slicekit XTAG adaptor) plus XTAG2 (debug adaptor), OR
   * XK-SK-L2-ST (Slicekit Starter Kit, containing all of the above).

Demonstration Application
+++++++++++++++++++++++++

Example usage of this module can be found within the XSoftIP suite as follows:

   * Package: sc_uart
   * Application: app_uart_fast

API and Programming Guide
-------------------------

API
+++

.. doxygenfunction:: uart_rx_fast
.. doxygenfunction:: uart_tx_fast

Example Usage
+++++++++++++

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

A main par that starts the logical cores:

.. literalinclude:: app_uart_fast/src/main.xc
   :start-after: //:: Main program
   :end-before: //

Example Application
-------------------

These modules can be evaluated wired back to back using app_uart_fast. To prepare the Slicekit core board to run this app connect wires between the 0.1" testpoints on the Triangle slot (or solder suitable headers on as shown in the picture below), such that ports 1A and 1E are connected. The headers corresponding to these ports are marked D0 and D12 respectively. 

The app can then be built and run. 

