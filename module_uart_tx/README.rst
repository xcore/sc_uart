Generic UART Transmitter
========================

:scope: General Use
:description: Uart with the full range of baud rate (up to 115.2KBaud), parity, stop bits and bits per character support
:keywords: UART
:boards: XK-SKC-L16, XA-SK-GPIO 

This module is completely parameterisable at run time. Unlike the alternative simple/fast uart, it can operate at the standard UART baud rates, and is fully configurable with respect to bits per character, stop bits and parity.

The default module code expects to run in its own logical core, but it would be possible to extract the key functions out as library calls so it could be integrated in a thread with other code, since a single UART Tx running at 115.2KBaud or below won't require much of the processing power of a logical core.
