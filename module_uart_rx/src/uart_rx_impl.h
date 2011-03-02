// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/** 
 * Implementation header file for UART Rx.
 */

#include "uart_rx.h"

void uart_rx_impl_start(chanend c, uart_rx_client_state &state);

unsigned char uart_rx_impl_get_byte(chanend c, uart_rx_client_state &state);

void uart_rx_impl_stop(chanend c, uart_rx_client_state &state);

void uart_rx_impl(in buffered port:1 rxd, unsigned char buffer[],
             unsigned buffer_size, unsigned baud_rate, unsigned bits,
             enum uart_rx_parity parity, unsigned stop_bits, chanend c);
