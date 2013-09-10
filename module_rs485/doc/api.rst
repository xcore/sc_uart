.. _sec_api:

RS485 API
=========

.. _sec_conf_defines:

Configuration Defines
---------------------

The file ``rs485_conf.h`` can be provided in the application source code, without it 
the default values specified in ``rs485.h`` will be used.
This file can set the following define:

**RS485_BUF_SIZE**

    This define sets size of the receive data buffer.


RS485 API
---------

.. _sec_conf_functions:

RS485 Types
+++++++++++

.. doxygentypedef:: rs485_interface_t
.. doxygentypedef:: rs485_parity_t
.. doxygentypedef:: rs485_state_t
.. doxygentypedef:: rs485_cmd_t
.. doxygentypedef:: rs485_buffer_state_t
.. doxygentypedef:: rs485_config_t

RS485 Function
++++++++++++++
.. doxygenfunction:: rs485_run

Configuration Functions
+++++++++++++++++++++++
.. doxygenfunction:: rs485_set_baud
.. doxygenfunction:: rs485_set_data_bits
.. doxygenfunction:: rs485_set_stop_bits
.. doxygenfunction:: rs485_set_parity
.. doxygenfunction:: rs485_get_status

Transmit Functions
++++++++++++++++++
.. doxygenfunction:: rs485_send_byte
.. doxygenfunction:: rs485_send_packet
