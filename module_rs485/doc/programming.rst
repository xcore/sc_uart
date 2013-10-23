RS485 Programming Guide
=======================

Key Files
---------

The ``rs485.h`` header file contains prototypes of all functions required to use use the RS485library. No other header files need to be included in the application. The API is described in 
:ref:`sec_api`.

Initialising the Interface
--------------------------

The interface is initialised and run using the rs485_run function.

Demo Applications
=================

app_rs485
---------

This application uses module_rs485 to receive data from an RS485 channel, and echoes the data back on
the same channel.

Makefile
++++++++

The Makefile is found in the top level directory of the
application. 

The application is for the sliceKIT Core Board so the TARGET variable needs to be set in the Makefile as::

  TARGET = XK-SKC-L2


rs485_conf.h
++++++++++++

The rs485_conf.h file is found in the src/ directory of the
application. This file contains a ``#define`` that configures
the RS485 component. 
The possible ``#define`` that can be set is described in :ref:`sec_conf_defines`.

If not set, default values in the rs485 header file will be used.

Within the demo application set the receive data buffer is set to 128 characters.

.. literalinclude:: app_rs485/src/rs485_conf.h


Top level program structure
+++++++++++++++++++++++++++

This application is contained in app_rs485.xc. Within this file is the ``main()`` function 
which runs the example application function, that takes the received data and sends it back out, and the RS485
server function.

To make use of the RS485 function library the app_rs485.xc must contain the following line::
    
  #include "rs485.h"

The RS485 interface is initialised to operate at 9600 baud, 8 data bits, 2 stop bits and a 
10 character time-out.

When a packet of data is received it is passed to the application function via the data channel, and is
then transmitted as a packet using the rs485_send_packet function.

app_rs485_demo
--------------

This application uses module_rs485 and demonstrates the usage module_rs485.

Makefile
++++++++

The Makefile is found in the top level directory of the
application. 

The application is for the sliceKIT Core Board so the TARGET variable needs to be set in the Makefile as::

  TARGET = XK-SKC-L2


rs485_conf.h
++++++++++++

The rs485_conf.h file is found in the src/ directory of the
application. This file contains a ``#define`` that configures
the RS485 component. 
The possible ``#define`` that can be set is described in :ref:`sec_conf_defines`.

If not set, default values in the rs485 header file will be used.

Within the demo application set the receive data buffer is set to 128 characters.

.. literalinclude:: app_rs485_demo/src/rs485_conf.h

common.h
++++++++++++

The common.h file is found in the src/ directory of the
application. This file contains a ``#define`` that configures
the RS485 component settings such as Baud rate, parity, data bit length. 
The possible ``#define`` that can be set is described in :ref:`sec_conf_defines`.

If not set, default values in the rs485 header file will be used.

Within the demo application set the receive data buffer is set to 128 characters.

.. literalinclude:: app_rs485_demo/src/rs485_conf.h

Top level program structure
+++++++++++++++++++++++++++

This application is contained in app_rs485_demo.xc. Within this file is the ``main()`` function 
which runs the example application function, that takes the received data and sets the parameter settings for the RS485
server function.

To make use of the RS485 function library the app_rs485_demo.xc must contain the following line::
    
  #include "rs485.h"

The RS485 interface is initialised to operate at 9600 baud, 8 data bits, 2 stop bits and a 
10 character time-out. This information can be changed in common.h header file.


