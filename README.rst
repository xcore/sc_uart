XCORE.com UART SOFTWARE COMPONENT
.................................

:Version: 
  unreleased

:Status:
  Feature complete with complete simulator plugin testbench

:Maintainer:
  Vishal Shah, Vishal_Shah@mindtree.com

Key Features
============

   * RX and TX in separate threads
   * Baud Rates up to 115.2K
   * Even, Odd or No Parity
   * 5,6,7 or 8 bits per byte
   * 1 or 2 stop bits
   * configurable buffer sizes  

Firmware Overview
=================

RX and TX are defined as functions which each run in their own virtual par which does not terminate, and have a simple client API. 

A simulator plugin testbench and demo applictions are included.

Known Issues
============

none

Required Modules
=================

xcommon

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the manitainer for this line.
