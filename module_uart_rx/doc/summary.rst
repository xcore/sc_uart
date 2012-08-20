UART Overview
=============

UART is one of the most basic asynchronous communication protocols. Also
known as RS-232, it transmits bits serially at a mutually agreed speed
without providing a clock. The speed is known as the *baud* rate, and is
typically something like 9600 baud, 115200 baud, or 10 Mbaud.

The most important characteristics are the following:

* The baud rate.

* The number of start bits, typically 1, sometimes 1.5

* The number of data bits, typically 7 or 8

* Whether a parity bit is present, and if so whether it is even parity or
  odd parity

* The number of stop bits, typically 1, sometimes 2.

UART Implementation Alternatives
--------------------------------

Two UART components are included in this repository, each consisting of two modules (one for each of RX and TX), summarised below:

+--------------+---------------------+------------+--------+---------------+---------------+-------------+
| Component    | modules             | Data rate  | Memory | Parity        | Bits Per Byte | Stop Bits   | 
+--------------+---------------------+------------+--------+---------------+---------------+-------------+
| Generic UART | module_uart_tx      | to 115.2K  | ~1K    | Even/Odd/None | 5/6/7/8       | 1 or 2      | 
+--------------+---------------------+------------+--------+---------------+---------------+-------------+


Generic UART
++++++++++++

This module is completely parameterisable at run time and will require a thread for each of RX and TX.


Other Uarts
+++++++++++

For an implementation of multi-uart suitable for applications where more than one uart is required, the sc_multi_uart component may be a better choice.


