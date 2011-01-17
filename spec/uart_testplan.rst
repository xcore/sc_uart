========================================================
 UART  Software Component Testplan 
========================================================

:Authors: Vishal Shah

:Company: Mindtree

:Version: 0.1

.. sectnum::


Introduction
============

This *internal* document details the testplan for testing the UART component.

Features
========

In addition to the features in the spec. These additional features are defined to aid finer granularity in the testing.

Setups
======

.. setup:: REVIEW
  :setup_time: 0

  Reviews require no setup. The review must take place preferably by
  someone other than the implementor.

.. setup:: XC1A
  :setup_time: 2

  Setup a host PC running windows with the latest development tools
  and an XC-1A dev card attached.

.. setup:: XC1A_LOOPBACK
  :setup_time: 2

  Setup a host PC running windows with the latest development tools
  and an XC-1A dev card attached with the following ports looped back
  on core 0:

        +--------+---------+
        |  1A    |   1B    |
        |  1C    |   1D    |
        |  1E    |   1F    |
        |  1G    |   1H    |
        +--------+---------+


.. setup:: SIMULATOR
  :setup_time: 1

  Setup a host PC with the latest released development tools.

Tests
=====

.. test:: sim_loopback_test
   :setup: SIMULATOR
   :configurations: BAUD_RATE_.*, BITS_PER_BYTE.* , PARITY_BITS.*, STOP_BITS_.*
   :features: UART_RX, UART_TX
   :test_time: 5

   This test runs 3 uart tx/rx loopbacks at varying rates.


.. test:: hw_loopback_test
   :setup: XC1A_LOOPBACK
   :configurations: STOP_BITS_.*, PARITY_BITS_.*, BITS_PER_BYTE_.*
   :features: UART_RX, UART_TX
   :test_time: 2

   This test runs 2 uart tx/rx loopbacks. The UART TX component is used to
   output data which is received by UART RX component.

.. test:: back2back_test
   :setup: XC1A
   :features: UART_RX, UART_TX
   :test_time: 2   

   The virtual COM port is used to transmit data to the UART RX component.
   All data received by the UART RX component is passed to the UART TX component
   which transmits it back to the virtual COM port.

.. test:: runtime_param_change_loopback
   :setup: XC1A_LOOPBACK
   :features: UART_RX, UART_TX
   :test_time: 2

   This test changes the BAUD_RATE, BITS_PER_BYTE, PARITY_BITS parameters at
   runtime using the configuration API.


.. test:: rx_buffer_overflow_exception_test
   :setup: XC1A_LOOPBACK
   :features: UART_RX, UART_TX, UART_RX_BUFFERING, BUILD_OPTION_UART_RX_EXCEPT_ON_OVERFLOW_ON
   :test_time: 2

   This test allows the UART RX buffer to overflow and checks that an exception
   is raised. Only valid when firmware built with the BUILD_OPTION_UART_RX_EXCEPT_ON_OVERFLOW_ON option.

.. test:: rx_buffer_overflow_drop_test
   :setup: XC1A_LOOPBACK
   :features: UART_RX, UART_TX, UART_RX_BUFFERING, BUILD_OPTION_UART_RX_EXCEPT_ON_OVERFLOW_OFF
   :test_time: 2

   This test allows the UART RX buffer to overflow and checks that the extra bits are dropped.
   Only valid when firmware built with the BUILD_OPTION_UART_RX_EXCEPT_ON_OVERFLOW_OFF option.

.. test:: loopback_demo_test
   :setup: XC1A_LOOPBACK
   :features: UART_RX, UART_TX, UART_DEMO_LOOPBACK
   :test_time: 2

   This test runs the loopback demo application provided with the UART
   components and checks tht data sent using the UART TX component is received
   by the UART RX component.

.. test:: back2back_demo_test
   :setup: XC1A
   :features: UART_RX, UART_TX, UART_DEMO_BACK_TO_BACK
   :test_time: 2

   This test runs the back to back demo application provided with the UART
   components and checks tht data sent to the UART RX component is echoed
   by the UART RX component.

.. test:: tx_buffer_block_test
   :setup: XC1A_LOOPBACK
   :features: UART_TX, UART_TX_BUFFERING,  UART_TX_CLIENT_API
 
    This test checks that the TX function blocks when tx buffer full. 


.. test:: tx_buffer_overrun_exception_test
   :setup: XC1A_LOOPBACK
   :features: UART_RX, UART_TX
 
    This test allows the UART TX buffer to transmit number of bytes more than the actuals and checks that an exception is raised.

.. test:: tx_buffer_bits_per_byte_exception_test
   :setup: XC1A_LOOPBACK
   :features: UART_RX, UART_TX
   
 
   This test allows the UART TX buffer to transmit byte with different number of bits per byte than that of configuration and checks that an exception  is raised.

.. test:: buffer_size_minimum_test
   :setup: XC1A_LOOPBACK
   :features: BUILD_OPTION_UART_TX_BUFFER_SIZE_BUFFER_SIZE_64_OFF,BUILD_OPTION_UART_RX_BUFFER_SIZE_BUFFER_SIZE_64_OFF
   
 
   This test checks for the minimum size ie. 1 byte for UART TX & UART_RX buffer and checks that an exception is raised,if data isnot communicated successfully from TX to RX buffer

.. test:: buffer_size_maximum_test
   :setup: XC1A_LOOPBACK
   :features: BUILD_OPTION_UART_TX_BUFFER_SIZE_BUFFER_SIZE_64_ON,BUILD_OPTION_UART_RX_BUFFER_SIZE_BUFFER_SIZE_64_ON
   
 
   This test checks for the maximum size ie. 64 bytes for UART TX & UART_RX buffer and checks that an exception is raised,if data isnot communicated successfully from TX to RX buffer.

