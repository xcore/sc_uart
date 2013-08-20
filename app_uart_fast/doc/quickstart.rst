.. _uart_fast_Quickstart:

Fast UART Demo Quickstart Guide
===============================

This simple FAST UART demonstration uses xTIMEcomposer Studio tools and targets the XP-SKC-L2 sliceKIT core board. It demonstrates back-to-back 10Mbps UART communication using the "Fast" UART component, which provides a simple. lightweight and fast UART peripheral.

This application instantiates both the module_uart_fast_rx and module_uart_fast_tx components looped back to one another to demonstrate basic usage.

Various other UART peripherals are available from XMOS offering different tradeoffs in performance, functionality and resources. The fast UART focusses on performance at the expense of resources, and consequently uses one core and a one bit port for each data direction.

Target boards other than sliceKIT can be used as long as the XMOS processor runs at 500MHz and two spare 1-bit ports are present to allow tx and rx to be brought out and looped back.

Hardware Setup
++++++++++++++

The XP-SKC-L2 sliceKIT Core board has four slots with edge connectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``. 

To setup up the system demonstrating the fast UART loopback running at 10Mbps on tile 0 (default for demo software):

   #. Disconnect any slice cards fitted from both ``STAR`` and ``TRIANGLE`` slice connectors. This avoids contention on the ports used in this example.
   #. Connect a flying lead between XD12 on the header by the ``TRIANGLE``  connector and XD13 on the header by the ``STAR`` connector. This connects the UART rx and tx pins together.

.. figure:: images/hardware_setup.*
   :width: 75mm
   :align: center

   Hardware Setup for FAST UART demo 

	
Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Simple/Fast Uart Loopback Example'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends (in this case, module_uart_rx & module_uart_tx) to be imported as well. 

   #. Click on the app_uart_fast item in the Project Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help using xTIMEcomposer, try the xTIMEcomposer tutorial, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer, on the right hand side of your screen, provides information on the xSOFTip components you are using. Select the app_uart_fast component in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2 and XTAG Adapter card) into the xCORE multicore microcontroller.

   #. Select the file ``main.xc`` in the ``app_uart_fast`` project from the Project Explorer. This resides in the /src directory.
   #. Click on the ``Run`` icon (the white arrow in the green circle). 
   #. At the ``Select Device`` dialog select ``XMOS XTAG-2 connect to L1[0..1]`` and click ``OK``. If you only see ``Simulator`` as the available target then please check to ensure the XTAG-2 debug adapter is properly connected to your PC. 
   #. Proper operation of the application can be verified by observing the console window of xTIMEcomposer studio to see that the producer task has printed the success message ``Sent 32 characters in 23 microseconds.`` and the consumer has verified the received array by printing ``Loopback test passed successfully.``. If the receiver does not print anything, or prints any statements like this ``Test failed. Value in array index..``, check to see that the loopback connection described in the hardware setup is correct.

Next Steps
++++++++++

Things to try now that the demo is running.

   #. Reduce the baud rate. Try changing the line ``#define BIT_PERIOD 10`` to ``#define BIT_PERIOD 868``. This will cause the bit period to be 8680ns, which slows down the baud the baud rate to 115Kbps (115207bps to be precise). You will see the resulting slower execution time of tx. The output should now reflect this by showing ``Sent 32 characters in 1988 microseconds.``

   #. Break the loopback. Remove the flying loopback lead from rx to tx and run the app again, to verify that the loopback test fails in the console window.

   #. Change the tile the application is running on. Change ``#define DEMO_TILE 0`` to  ``#define DEMO_TILE 1``. 

You must also change the flying lead to connect XD12 and XD13 to the ``SQUARE`` and ``CIRCLE`` side (tile 1). Build and run the application again. It is now running on a different tile to before, however functionality is exactly the same. 

