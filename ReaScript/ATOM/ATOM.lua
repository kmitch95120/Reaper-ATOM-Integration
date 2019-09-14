local ATOM = { }

-- One place to turn ShowConsoleMsg Debug On or Off
function ATOM.dbg_msg(message)
  if reaper.HasExtState("ATOM", "debug") then
    reaper.ShowConsoleMsg(message)
  end
end

function ATOM.message(message)
  reaper.ShowConsoleMsg(message)
end

function ATOM.debug(op)
  if string.lower(op) == "enable" then
    reaper.SetExtState("ATOM", "debug", "1", 0)
    ATOM.dbg_msg("\nDebug set to Enable")
  elseif string.lower(op) == "disable" then
    reaper.DeleteExtState("ATOM", "debug", 1)
    ATOM.dbg_msg("\nDebug set to Disable")
  else
    ATOM.message("\nATOM:debug() - Invalid Operation Requested")
      return -1 -- invalid option
  end
end

-- Find and return the first ATOM Controller
--
-- Tries to locate a MIDI Output device with "ATOM" in its name.
--
--  If successful, the device ID + offset of 16 (for external devices)
--  is loaded into an External State key called "outID".
--
--  if not successful, "outID" is deleted, if it ever existed. 
--
function ATOM.find()

  local devID = -1
  local count = reaper.GetNumMIDIOutputs() -- The total number of MIDI Outputs
  
  for x=1, count, 1 do
    rc, name = reaper.GetMIDIOutputName(x, "")
    if rc then
      if string.find(name, "ATOM") then -- check for target_Name in device name
        devID = x -- Found the output target devID
        break
      end
    end
  end
  
  if devID > -1 then
    devID = devID + 16 -- Offset for external devices
    reaper.SetExtState("ATOM", "outID", tostring(devID), 0)
  else
    reaper.DeleteExtState("ATOM", "outID", 1)
  end
end


-- Configure ATOM Native Control Mode
-- "op" is either "enable" or "disable"
function ATOM.nc_mode(op)
  
-- Go find the ATOM Controller
  ATOM.find()

-- then we need to get the outID for the ATOM
  if reaper.HasExtState("ATOM", "outID") then 
    devID = reaper.GetExtState("ATOM", "outID")
  else
    ATOM.message("\nATOM:nc_mode() - Couldn't find an ATOM Controller")
    return -1
  end
    
  if string.lower(op) == "enable" then
    reaper.StuffMIDIMessage(devID, 143, 0, 127) -- Note Off Note 0 Value 127
    ATOM.dbg_msg("\nNC Mode set to Enable")
  elseif string.lower(op) == "disable" then
    reaper.StuffMIDIMessage(devID, 143, 0, 0) -- Note Off Note 0 Value 0 
    ATOM.dbg_msg("\nNC Mode set to Disable")
  else
    ATOM.message("\nATOM:nc_mode() - Invalid Operation " .. tostring(op) .. " Requested\n")
      return -1 -- invalid option
  end
end

-- Handle Shift Key 
function ATOM.handleShift(value)

  local devID
  
  if reaper.HasExtState("ATOM", "outID") then
    devID = tonumber(reaper.GetExtState("ATOM", "outID"))
  else
    -- Can't do anything without a valid outID
    return -1
  end
  
  if value == 127 then -- Pressed
    reaper.SetExtState("ATOM", "shift_state", "1", 0)
    reaper.StuffMIDIMessage(devID, 176, 32, 127) -- Set Button LED Bright  
  elseif value == 0 then -- Released
    reaper.DeleteExtState("ATOM", "shift_state", 1)
    reaper.StuffMIDIMessage(devID, 176, 32, 0) -- Set Button LED Dim   
  else
    -- Ignore
  end
end

function ATOM.handlePlay(value)
  
  local devID
  
  if reaper.HasExtState("ATOM", "outID") then
    devID = tonumber(reaper.GetExtState("ATOM", "outID"))
  else
    -- Can't do anything without a valid outID
    return -1
  end

  if reaper.HasExtState("ATOM", "shift_state") then
    shifted = 1
  else
    shifted = 0
  end

  if value == 127 then
    if shifted == 1 then
      -- Repeat
      reaper.GetSetRepeat(2) -- Toggle Repeat
      if reaper.GetSetRepeat(-1) == 0 then -- Repeat Off     
        ATOM.setPlayGreen()
      else -- Repeat On
        ATOM.setPlayGreen()
      end
    else
      -- Play    
      reaper.Main_OnCommand(1007, 0) -- Transport: Play
      ATOM.setButtonLED("bright", 109) -- Play Bright
      ATOM.setButtonLED("dim", 111) -- Stop Dim
    end
  end
end

--
--
function ATOM.handleStop(value)
  
  local devID
  
  if reaper.HasExtState("ATOM", "outID") then
    devID = tonumber(reaper.GetExtState("ATOM", "outID"))
  else
    -- Can't do anything without a valid outID
    return -1
  end

  if value == 127 then
    reaper.Main_OnCommand(1016, 0) -- Transport: Stop
    ATOM.setButtonLED("bright", 111)-- Stop Bright  
    ATOM.setButtonLED("dim", 109)-- Play Dim  
  end
end

function ATOM.handleRecord(value)
  
  local devID
  
  if reaper.HasExtState("ATOM", "outID") then
    devID = tonumber(reaper.GetExtState("ATOM", "outID"))
  else
    -- Can't do anything without a valid outID
    return -1
  end

  if value == 127 then
    reaper.Main_OnCommand(1013, 0) -- Transport: Record
    ATOM.setButtonLED("bright", 107) -- Record Bright
    ATOM.setButtonLED("bright", 109) -- PlayBright
    ATOM.setButtonLED("dim", 111) -- Stop Dim
  end
end

--
--
function ATOM.setButtonLED(mode, num)
  local devID
  if reaper.HasExtState("ATOM", "outID") then 
    devID = reaper.GetExtState("ATOM", "outID")
    
  else
  -- This should never get hit since the existance of outID 
  -- should have checked before the call to this function. 
    ATOM.message("\nATOM: Can't find outID")
    return -1
  end

  if string.lower(mode) == "bright" then
    reaper.StuffMIDIMessage(devID, 176, tonumber(num), 127)
    ATOM.dbg_msg("\nSet Button to Bright")
  elseif string.lower(mode) == "dim" then
    reaper.StuffMIDIMessage(devID, 176, tonumber(num), 0)
    ATOM.dbg_msg("\nNC Mode set to Disable")
  else
    ATOM.message("\nATOM:SetButtonLED() - Invalid Mode Requested")
      return -1 -- invalid option
  end
end

function ATOM.setPlayBlue()
  local devID
  if reaper.HasExtState("ATOM", "outID") then 
    devID = reaper.GetExtState("ATOM", "outID")
  else
  -- This should never get hit since the existance of outID 
  -- should have been checked before the call to this function. 
    ATOM.message("\nATOM: Can't find outID")
    return -1
  end

  reaper.StuffMIDIMessage(devID, 177, 109, 0) -- Channel 2 (Red)
  reaper.StuffMIDIMessage(devID, 178, 109, 0) -- Channel 3 (Green)
  reaper.StuffMIDIMessage(devID, 179, 109, 52) -- Channel 4 (Blue)
end

function ATOM.setPlayGreen()
  local devID
  if reaper.HasExtState("ATOM", "outID") then 
    devID = reaper.GetExtState("ATOM", "outID")  
  else
  -- This should never get hit since the existance of outID 
  -- should have been checked before the call to this function. 
    ATOM.message("\nATOM: Can't find outID")
    return -1
  end

  reaper.StuffMIDIMessage(devID, 177, 109, 0) -- Channel 2 (Red)
  reaper.StuffMIDIMessage(devID, 178, 109, 52) -- Channel 3 (Green)
  reaper.StuffMIDIMessage(devID, 179, 109, 0) -- Channel 4 (Blue)
end

return ATOM

