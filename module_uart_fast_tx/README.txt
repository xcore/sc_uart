
Simple/Fast UART Transmitter
****************************

scope:
   Early Development

description:
   Basic Uart Transmitter where the functionality of the full generic
   uart transmitter module is not required

keywords:
   UART

boards:
   XK-SKC-L2

This basic uart transmitter is very simple, and implements baud rates
which can be derived directly from the 100 MHz reference clock. Baud
rates like 115.2KBaud are not supported. This simplicity enables this
module to achieve very high baud rates well in excess of 1 MBaud.
