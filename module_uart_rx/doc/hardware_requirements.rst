Evaluation Platforms
====================

Recommended Hardware
--------------------

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-GPIO plus XA-SK-ATAG2 (Slicekit XTAG adaptor) plus XTAG2 (debug adaptor), OR
   * XK-SK-L2-ST (Slicekit Starter Kit, containing all of the above).

Demonstration Application
-------------------------

Example usage of this module can be found within the XSoftIP suite as follows:

   * Package: sw_gpio_examples
   * Application: app_slicekit_com_demo

Hardware Requirements
======================

The XA-SK-GPIO mentioned above incorporates an RS232 transceiver which will be necessary for establshing a connection between this module and a typical PC com port. See the XA-SK-GPIO pages for more details of components and connectivity. 

If RS-232 signalling levels are not required and the other end of the cable is employing normal TTL signalling levels then the transceiver is not required.

