UART software
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

module_uart_rx, module_fast_tx
------------------------------

This module is completely parameterisable. Performance figures are to be
confirmed.

module_uart_fast_rx, module_fast_uart_tx
----------------------------------------

This module is a simple implementation of a UART that requires a thread for
transmission, a thread for reception, and requires very little memory. It
can transmit data at a high baud rate (up to 10 Mbaud).

It is fixed to 8 bits, a single start bit, no parity, and a single stop
bit. All of those parameters can be changed by editing the module. THe baud
rate is parameterisable, but has to be a whole division of 100 MHz.

+---------------+------------+--------+-------------+
| Functionality | Data rate  | Memory | Status      |
+---------------+------------+--------+-------------+
| Tx            | 10 Mbaud   | 0.25K  | Implemented |
+---------------+------------+--------+-------------+
| Rx            | 10 Mbaud   | 0.25K  | Implemented |
+---------------+------------+--------+-------------+

Note that the code is easy to understand; it comprises the example from the
XC programming manual. The TX code does not have to run in a thread of its
own, and can be called as a function instead. This is to be implemented.

