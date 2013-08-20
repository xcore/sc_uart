// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/** This function implements a fast UART. It needs an unbuffered 1-bit
 * port, a streaming channel end, and a number of port-clocks to wait
 * between bits. It waits for a token on the streaming channel, and then
 * sends a start bit, 8 bits, and a stop bit. On a 62.5 MIPS thread this
 * function should be able to keep up with a 10 MBit UART sustained
 * (provided that the streaming channel can keep up with it too).
 * 
 * This function does not return.
 *
 * \param p      output port, 1 bit port on which data should be transmitted
 * 
 * \param c      input streaming channel - output bytes of this channel (or
 *               words if you want to output 4 bytes at a time)
 *
 * \param clocks number of clock ticks between bits. This number depends on the clock
 *               that you have attached to port p; assuming it is the standard 100 Mhz
 *               reference clock then clocks should be at least 10.
 */
void uart_tx_fast(out port p, streaming chanend c, int clocks);

/** This function initialises the fast uart I/O. Uses built-in function to
 * setup port mode.
 *
 * \param p      output port, 1 bit port on which data is transmitted
 *
 * \param clkblk the clock source for the clocked port
 */
void uart_tx_fast_init(out port p, const clock clkblk);


