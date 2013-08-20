Simple/Fast UART TX component
=============================

:scope: Early Development
:description: Basic and fast UART without FIFO
:keywords: Serial simple fast UART
:boards: XP-SKC-L16

This is a single logical core, fast UART TX component suitable for high speed applications. It uses a core per rx or tx channel but is able to stream continuously at up to 10Mbps, using a 62.5MIPS core

Features
--------

  * Single core implementation
  * Fixed 1, 8, n, 1 configuration
  * No FIFO
  * High speed
  * Baud rate specified as a bit period in multiples of 10ns

Known Issues
------------

  * None