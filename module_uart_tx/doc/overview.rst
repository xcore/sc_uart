UART TX Overview
================

UART is one of the most basic asynchronous communication protocols. Also
known as RS-232, it transmits bits serially at a mutually agreed speed
without providing a clock. The speed is known as the *baud* rate.


This module comprises a UART transmitter with two variants. One runs
on its own logical core and buffers any characters send to it. The
other variant is unbuffered but its work can be distributed over other
cores so it requires no logical core of its own. There is a companion
module which implements the receiver function.

Features
--------

Additional configurable settings are:

   * Data Rate: to 115.2K
   * Parity: Even/Odd/None
   * Bits Per Byte: 5/6/7/8
   * Stop bits: 1 or 2



