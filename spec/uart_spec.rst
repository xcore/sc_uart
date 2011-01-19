=============================================
UART Components Specification
=============================================
:Version: 1.0
:authors: David Lacey

.. sectnum::

Introduction
============

The UART (Universal Asynchronous Receive and Transmit) components
provides a general purpose components for serial communcation with
other devices. There will be two components available:

  * UART Tx - UART communication from the XCore to an external device
  * UART Rx - UART communication from an external device to the XCore

These will be available as seperate components in Arkanoid. The
components will be composable and can share a thread with other
components. 

Functional Specification
========================

.. feature:: UART_TX

      A UART Tx component will allow the client to send data over a
      serial link. It will be composable on a thread with other
      components and communicate with the client via a channel API. 

.. feature:: UART_TX_BUFFERING
    :parents: UART_TX

     The UART TX component will buffer data sent from the client and
     queue the data to be sent over the serial link. In the case where
     the buffer is full, the component will block the client from
     sending any more data until there is room in the buffer.

.. feature:: BUILD_OPTION_UART_TX_BUFFER_SIZE
   :parents: UART_TX
       
     A ``#define`` will set the size of the UART Tx component buffer.

.. feature:: UART_RX

      A UART Rx component will allow the client to send data over a
      serial link.
     
.. feature:: UART_RX_BUFFERING
     :parents: UART_RX

     The UART RX component will buffer data received over the serial
     link and queue the data to be sent to the client. In the case where
     the buffer is full incoming bytes of data will be dropped.

.. feature:: BUILD_OPTION_UART_RX_BUFFER_SIZE
   :parents: UART_RX

     A ``#define`` will set the size of the UART Rx component buffer.

.. feature:: BUILD_OPTION_UART_RX_EXCEPT_ON_OVERFLOW
     :config_options: OFF | ON
     :parents: UART_RX
     
     There will be a build option to raise an exception on RX buffer
     overflow for debugging purposes.

.. feature:: BAUD_RATE
   :summarize_options:
   :config_options: 24K | 96K | 115.2K
   :parents: UART_TX, UART_RX

   The components will have baud rate as a parameter instantiated when
   the component is run. Rates will be supported up to a maximum of 115200.
   THis testplan only specifies 24K, 96K and 115.2K for testing though.

.. feature:: PARITY_BITS
   :summarize_options:
   :config_options: none | even | odd
   :runtime:
   :parents: UART_TX, UART_RX

   The component will support UART with none, even and odd parity.

.. feature:: BITS_PER_BYTE
   :summarize_options:
   :config_options: 5 | 6 | 7 |8
   :runtime:
   :parents: UART_TX, UART_RX

   The component will support UART with configurable bits per byte (bits per character).

.. feature:: STOP_BITS
   :summarize_options:
   :config_options: 1 | 2
   :runtime:
   :parents: UART_TX, UART_RX

   The component will support UARTS with a one or two stop bits.


Limitations
===========

The component has the following limitations:

   * No uart side flow control is implemented. The client APi does have flow control.
   * No multi-sampling is done.

API
===

This section describes the API of the two UART components.

UART Tx Component
-----------------

The component will run in a virtual par with the following function which does not terminate.

     * void UartTx(int baud_rate, out buffered port:1 p, chanend c)

.. feature:: UART_TX_CLIENT_API
   :parents: UART_TX

 
   The component has one client function call:

     * void UartTxSendByte(chanend c, unsigned x)

   This function sends a single byte of data to be transmitted over
   the serial link. This byte will be buffered and queued to send. If
   the buffer is full, this function will not return until space 
   has been made in the buffer. This function is not selectable.
  

UART Rx Component
-----------------

The component will run in a virtual par with the following function which does not terminate.

     * UartRx(int baud_rate, out buffered port:1 p, chanend c)


The component has one client function call:

     * void UartRxGetByte(chanend c, unsigned &x)

This function receives a byte from the UART Rx component buffer. If
called standalone it will block until a byte is ready to
receive. The function can also be called in a select::
 
           select 
            {
            case UartRxGetByte(c, x):
             ...
            break;
            ...
            }
  
In this usage model, the select case becomes active when the
component has data ready.
      
Due to the buffering in the component the client does not need to 
call this function at the rate the component is receiving data
i.e. the client cannot block out the component.

Expected Resource Usage
=======================

Threads
-------

The UART components will run on one thread which can be shared with
other components. It is expected that at least 2 Rx components and 2
Tx components can share one thread at maximum baud rate.

Ports
-----

The Rx and Tx components will each use 1 x 1-bit port.

Memory
------

Aside from code size the main memory resource usage will be though the
buffers which are configurable.

Timers/Clocks
-------------

Each component will use one timer and will need 1 timer and use one
clock block which is expected to be set to the reference frequency of 100Mhz.


Meta Information Summary
========================

The component composer will have the following parameter(s) for both
the Rx and Tx components:

   * Baud rate (see `BAUD_RATE`_)

Demo Applications
=================

In order to demonstrate uart functionality this component will have
the following demo programs developed.

.. feature:: UART_DEMO_LOOPBACK

   This application will send data out via the Tx component and
   receive via the Rx component and check that the data matches
   (i.e. it expects an external loopback).

.. feature:: UART_DEMO_BACK_TO_BACK

   This application will receive via the rx component and echo the
   data back out of the Tx component.

 
Related Documents
=================

* http://en.wikipedia.org/wiki/Universal_asynchronous_receiver/transmitter
