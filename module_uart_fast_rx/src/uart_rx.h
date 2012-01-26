// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/** This function implements a fast UART. It needs an unbuffered 1-bit
 * port, a streaming channel end, and a number of port-clocks to wait
 * between bits. It receives a start bit, 8 bits, and a stop bit, and
 * transmits the 8 bits over the streaming channel end as a single token.
 * On a 62.5 MIPS thread this function should be able to keep up with a 10
 * MBit UART sustained (provided that the streaming channel can keep up
 * with it too).
 * 
 * This function does not return.
 *
 * \param p      input port, 1 bit port on which data comes in
 * 
 * \param c      output streaming channel - read bytes of this channel (or
 *               words if you want to read 4 bytes at a time)
 *
 * \param clocks number of clock ticks between bits. This number depends on the clock
 *               that you have attached to port p; assuming it is the standard 100 Mhz
 *               reference clock then clocks should be at least 10.
 */
extern void uart_rx_fast(in port p, streaming chanend c, int clocks);
