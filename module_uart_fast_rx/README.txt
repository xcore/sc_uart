
Simple/Fast UART Receiver
*************************

scope:
   Early Development

description:
   Basic Uart Receiver where the functionality of the full generic
   uart receiver module is not required

keywords:
   UART

boards:
   XK-SKC-L2

This basic uart receiver is very simple, and implements baud rates
which can be derived directly from the 100 MHz reference clock. Baud
rates like 115.2KBaud are not supported. This simplicity enables this
module to achieve very high baud rates well in excess of 1 MBaud.
