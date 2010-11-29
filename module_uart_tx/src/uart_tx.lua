-------------------------------------------------------------------------------
-- Descriptive metadata
-------------------------------------------------------------------------------

componentName = "uart_tx"
componentFullName = ""
alternativeNames = { }
componentDescription = "UART transmit"
componentVersion = "1v0"

-------------------------------------------------------------------------------
-- Source generation functions
-------------------------------------------------------------------------------
  
function getIncludes() 
  return "#include \"uart_tx.h\"\n"
end

function getGlobals()
  return "out port uart_tx_port_" .. component.id .. " = " .. component.port[0] .. ";\n"
end

function getChannels()
  return "chan uart_tx_chan_" .. component.id .. ";\n"
end

function getLocals()
  return "unsigned char tx_buffer[" .. component.params.buffer_size .. "];\n"
end

function getCalls()
  return "uart_tx(" ..
           "uart_tx_port_" .. component.id ..
           ", tx_buffer" ..
           ", " .. component.params.buffer_size ..
           ", " .. params.max_baud ..
           ", *" ..
           ", UART_TX_PARITY_NONE" ..
           ", 1" ..
           ", uart_tx_chan_" .. component.id
         .. ");\n";
end

-------------------------------------------------------------------------------
-- Documentation functions
-------------------------------------------------------------------------------

function getPortName(i)
  return "UART_TX"
end

function getPortDescription(i)
  return "Transmit Data"
end

function getPortDirection(i)
  return "out"
end

function getDatasheetSummary()
  return "UART transmitter"
end

function getDatasheetDescription()
  return "The UART transmitter component supports transmitting serial data at up to "
         .. component.params.max_baud .. " baud."
end

-------------------------------------------------------------------------------
-- Parameter descriptions.
-------------------------------------------------------------------------------

configPoints =
{
  max_baud =
  {
    short   = "Maximum baud rate",
    long    = "Maximum baud rate which the component can be configured to transmit at",
    help    = "",
    units   = "baud",
    sortKey = 1,
    paramType = "int",
    max     = 115200,
    min     = 1,
    default = 57600
  },
  buffer_size =
  {
    short   = "Buffer size",
    long    = "Size of transmit buffer",
    help    = "",
    units   = "bytes",
    sortKey = 2,
    paramType = "int",
    max     = 256,
    min     = 1,
    default = 64
  }
}

configSets =
{
  typical = { max_baud=57600, buffer_size=64 },
  baud_115200 = { max_baud=115200, buffer_size=64 }
}

-------------------------------------------------------------------------------
-- Source generation functions
-------------------------------------------------------------------------------

function getStaticMemory()
  return buildResults.typical.memoryStatic
end

function getDynamicMemory()
  return (buildResults.typical.memoryStack - 64) + component.params.buffer_size
end

function getNumberOfChanendArguments()
  return 1
end

function getNumberOfTimers()
  return buildResults.typical.numTimers
end

function getNumberOfThreads()
  return buildResults.typical.numThreads
end

function getNumberOfClockBlocks()
  return 0
end

function getNumberOfLocks()
  return 0
end

function getNumberOf1BitPorts()
  return 1
end

function getNumberOf4BitPorts()
  return 0
end

function getNumberOf8BitPorts()
  return 0
end

function getNumberOf16BitPorts()
  return 0
end

function getNumberOf32BitPorts()
  return 0
end

function hardcodedPorts()
  return {}
end

function requiedPhys()
  return {}
end
