RS485 Quickstart Guide
===========================

.. _Slicekit_RS485_Demo_Quickstart:

RS485 Demo app : Quick Start Guide
----------------------------------

This simple demonstration of xTimeComposer Studio functionality uses the XA-SK-ISBUS Slice Card together with the xSOFTip rs485 component to:

   * Receive RS485 data packets
   * Transmit the received packet back to the RS485 bus

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``. 

To setup up the system:

   #. Connect XA-SK-ISBUS Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``TRIANGLE``.
   #. Connect a USB to RS485 converter pins A, B and GND to the ISBUS slice P1 connector.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC. Note that a USB cable is not provided with the Slicekit starter kit.
   #. Switch on the power supply to the Slicekit Core board.

.. figure:: images/hardware_setup.png
   :align: center

   Hardware Setup for RS485 Demo
   
	
Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTimeComposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Slicekit RS485'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTimeComposer. This will also cause the modules on which this application depends (in this case, module_rs485) to be imported as well. 
   #. Click on the app_rs485 item in the Explorer pane then click on the build icon (hammer) in xTimeComposer. Check the console window to verify that the application has built successfully.

For help in using xTimeComposer, try the xTimeComposer tutorials, which you can find by selecting Help->Tutorials from the xTimeComposer menu.

Note that the Developer Column in the xTimeComposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the ``RS485`` component in the xSOFTip Browser, and you will see its description together with links to more documentation for this component. Once you have briefly explored this component, you can return to this quickstart guide by re-selecting  ``'Slicekit RS485 Demo'`` in the xSOFTip Browser and clicking once more on the Quickstart  link for the ``RS485 Demo Quickstart``.
    
Serial Terminal Setup Examples
++++++++++++++++++++++++++++++

PuTTY
.....

   #. Open the PuTTY program, the PuTTY Configuration Dialog should be showing
   #. Select the 'Serial' category, under 'Connection'
   #. Set the 'Serial line to connect to' to match the COM port associated with the USB to RS485 device (this can be found in the device manager if not known)
   #. Set the 'Speed (baud)' option to 9600 (or to whatever baud has been selected in the software)
   #. Set the 'Data bits' option to 8
   #. Set the 'Stop bits' option to 2
   #. Select 'None' from the 'Parity' drop-down
   #. Select 'None' from the 'Flow control' drop-down
   #. Select the 'Session' Category
   #. Select the 'Serial' radio button 
   #. Click 'Open'
   #. Type 012345678 in to the terminal window, you should see the output as below
   
   .. figure:: images/PuTTY_Config.png
   :align: center

   PuTTY Configuration Dialog
   
   .. figure:: images/PuTTY_Result.png
   :align: center
   
   PuTTY Terminal Output
   
RealTerm
........
   
   #. Open the RealTerm program
   #. Select the 'Port' tab
   #. Select '9600' (or whatever baud has been selected in the software)from the 'Baud' drop-down
   #. Select the COM port allocated to the USB to RS485 device from the 'Port' drop-down
   #. Select the 'None' radio button in the 'Parity' group
   #. Select the '8 bits' radio button in the 'Data Bits' group
   #. Select the '2 bits' radio button in the 'Stop Bits' group
   #. Select the 'None' radio button in the 'Hardware Flow Control' group
   #. Click the 'Change' button
   #. Select the 'Display' tab
   #. Click in the terminal window and type 012345678, you shoule see the output as below
   
   .. figure:: images/RealTerm_Config.png
   :align: center

   RealTerm Configuration Dialog
   
   .. figure:: images/RealTerm_Result.png
   :align: center
   
   RealTerm Terminal Output

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2 and Xtag Adaptor card) into the xCORE multicore microcontroller.
 
   #. Using a serial terminal application, connect to the RS485 to USB converter, set to 9600 baud, 8 data bits, 2 stop bits, no parity.
   #. Click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear asking which device to cvonnect to. Select ``XMOS XTAG2``.
   #. Welcome message with list of supported commands is displayed on the Terminal Window. The following screenshot shows the information displayed on the screen.
   
   .. figure:: images/welcome_message.png
   :align: center
   
   Welcome Message on  Terminal Output
   
   #. Press character f in the Terminal. Input some data from terminal and press ``CTRL + D`` after finishing data input.
   #. The input dtaa is echoed back to the terminal as shown in the following screenshot.
   
    .. figure:: images/data_display.png
   :align: center
   
   Input data echoed back on  Terminal Output
   
   #. Press character p in the Terminal. The following information is displayed on the screen 
    .. figure:: images/parity_settings.png
   :align: center
   
   Parity settings Message on  Terminal Output
   
   #. Press character 1 on the terminal and restart the terminal with parity changed as ``EVEN`` and select ``f`` option and input data, you should see data echoed back after.
   #. In the same way, you can set the parameters like ``parity``, ``baudrate``, ``length of databits``.
   #. In any instance press ``h`` to display the help menu.
   #. The application uses baud rate upto 115200. But the RS485 module (module_rs485) supports upto 1 Mbps.
   
Next Steps
++++++++++

Look at the Code
................

   #. Examine the application code. In xTIMEcomposer navigate to the ``src`` directory under app_rs485_demo and double click on the app_rs485_demo.xc file within it. The file will open in the central editor window.
   #. Find the main function and note that it runs the run_rs485() function on a single logical core, and a second application function on a second logical core.
   #. The common.h file in the scr directory contains all the definitions such as baud rate, parity, stopbits, data length.
   #. At the top of the common.h file try changing the baud rate definition to a different value, change the baud rate in your chosen terminal application and reconnect.
   #. Find the consume function. Note that the function waits for the rs485_run function to send it some data, buffer that data and then transmit the packet back. Try manipulating the data before returning it, eg. repeat it.

:ref:`Slicekit_RS485_Quickstart`
   
