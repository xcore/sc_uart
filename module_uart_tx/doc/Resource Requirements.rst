Resource Requirements
=====================

This section provides an overview of the required resources of the component so that the application designer can operate within these constraints accordingly.

XCORE Ports
+++++++++++

The following ports are required for each of the receive and transmit functions - 

.. list-table::
    :header-rows: 1
    
    * - Operation
      - Port Type
      - Number required
      - Direction
      - Port purpose / Notes
    * - UART_RX
      - 1 bit port
      - 1
      - Input
      - Uart RX to receive data
    
xCore Logical Processors
++++++++++++++++++++++++

.. list-table::
    :header-rows: 1
    
    * - Operation
      - Logical Processors Count
      - Notes
    * - Uart Transmit Thread
      - 1
      - Single thread (Logical Processor) 

     
Channel Usage
+++++++++++++++

.. list-table::
    :header-rows: 2
    
    * - Operation
      - Channel Usage & Type
    * - None
      - None

Timers Usage
+++++++++++++++

.. list-table::
    :header-rows: 1
    
    * - Operation
      - No of Timers Used
    * - xTime
      - 2




