Overview
========

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

Uart Modules
------------

Four uart modules are covered by this document, as shown below.

+--------------+---------------------+------------+--------+---------------+---------------+-------------+
| Component    | modules             | Data rate  | Memory | Parity        | Bits Per Byte | Stop Bits   | 
+--------------+---------------------+------------+--------+---------------+---------------+-------------+
| Generic UART | module_uart_tx      | to 115.2K  | ~1K    | Even/Odd/None | 5/6/7/8       | 1 or 2      | 
|              |---------------------+------------+--------+---------------+---------------+-------------+
|              | module_uart_rx      | to 115.2K  | ~1K    | Even/Odd/None | 5/6/7/8       | 1 or 2      | 
+--------------+---------------------+------------+--------+---------------+---------------+-------------+
| Simple UART  | module_uart_fast_tx | 10 Mbaud   | 0.25K  | None          | 8             | 1           |
|              |---------------------+------------+--------+---------------+---------------+-------------+
|              | module_uart_fast_tx | 10 Mbaud   | 0.25K  | None          | 8             | 1           |
+--------------+---------------------+------------+--------+---------------+---------------+-------------+

Generic UART
------------

This module is completely parameterisable at run time and will require a thread for each of RX and TX. Unlike the simple uart below, it can operate at the standard UART baud rates.

Simple Uart
-----------

This module is a much simpler implementation of a UART that will require a whole thread for RX and deliver up to 10 Mbaud. TX could be called as a function, and hence share a thread with other functionality although this will affect the TX baud rate achieved,and this usage is not shown. 

It is fixed to 8 bits, a single start bit, no parity, and a single stop bit. All of those parameters could be changed by altering the source code. 

*The baud rate is parameterisable, but has to be a whole division of 100 MHz.* This may make it unsuitable for some applications requiring a very particular baud rate.

Note that the code is easy to understand; it comprises the example from the XC programming manual.

Other Uarts
-----------

For an implementation of multi-uart suitable for applications where more than one uart is required, the module_multi_uart component may be a better choice, which offers up t 8 uarts in two threads. In general, designs requring a single basic uarts are often most optimally constructed by incorporating the TX functionality inline with other application functions, and having a separate thread for RX. A fully optimised design incorporating uarts may therefore merit some modifications of these components.


