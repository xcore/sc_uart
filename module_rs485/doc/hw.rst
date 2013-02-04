Evaluation Platforms
====================

.. _sec_rs485_hardware_platforms:

Recommended Hardware
--------------------

Slicekit
++++++++

This module may be evaluated using the Slicekit Modular Development Platform. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-XTAG2 (Slicekit XTAG adaptor) 
   * XA-SK-ISBUS (SliceKit Industrial Bus Slice)

Demonstration Applications
--------------------------

app_rs485
+++++++++

The demostration application requires the three RS485 connections (A,B and GND_ISO) to be connected to 
an appropriate USB to RS485 converter (eg. Amplicon USB-485Ui) configured in half-duplex mode with no 
local echo. A serial terminal program on a PC can then be used to send and recieve the echoed data.

Example usage of this module can be found within the XSoftIP suite as follows:

   * Package: 
   * Application: 
