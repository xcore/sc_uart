Evaluation Platforms
====================

.. _sec_rs485_hardware_platforms:

Recommended Hardware
--------------------

sliceKIT
++++++++

This module may be evaluated using the sliceKIT Modular Development Platform. Required board SKUs are:

   * XP-SKC-L16 (sliceKIT L16 Core Board) plus XA-SK-XTAG2 (sliceKIT XTAG adaptor) 
   * XA-SK-ISBUS (sliceKIT Industrial Serial Bus slice)

Demonstration Applications
--------------------------

RS485 Terminal Console Demo (app_rs485)
+++++++++++++++++++++++++++++++++++++++

This demonstration application requires the three RS485 connections (A,B and GND_ISO) to be connected to 
an appropriate USB to RS485 converter (eg. Application USB-485Ui) configured in half-duplex mode with no 
local echo. A serial terminal program on a PC can then be used to send and receive the echoed data.

