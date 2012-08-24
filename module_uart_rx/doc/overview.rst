UART RX Overview
================

UART is one of the most basic asynchronous communication protocols. Also
known as RS-232, it transmits bits serially at a mutually agreed speed
without providing a clock. The speed is known as the *baud* rate.

This module comprises a UART receiver that runs in one thread, with the client functions required to communicate with it over channels. There is a companian module which implements the transmitter function.


Features
--------

Additional configurable settings are:

   * Data Rate: to 115.2K
   * Parity: Even/Odd/None
   * Bits Per Byte: 5/6/7/8
   * Stop bits: 1 or 2



