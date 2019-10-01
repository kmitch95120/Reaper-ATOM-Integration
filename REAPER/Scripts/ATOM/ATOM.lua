colors = reaper.GetResourcePath() .. "/Scripts/ATOM/COLORS.lua"
dofile(colors)

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

function ATOM.start_polling()
    
  if reaper.HasExtState("ATOM", "outID") then 
    val = reaper.NamedCommandLookup("_RSf8e4f6430c6d03c69b2d5f2519ef97465317e503")
    reaper.Main_OnCommand(val, 0)
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

  if value == 127 then
    if reaper.HasExtState("ATOM", "shift_state") then
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

function ATOM.handleClick(value)

  local devID

  if reaper.HasExtState("ATOM", "outID") then
    devID = tonumber(reaper.GetExtState("ATOM", "outID"))
  else
    -- Can't do anything without a valid outID
    return -1
  end

  if value == 127 then
    if reaper.HasExtState("ATOM", "shift_state") then
      -- Count-in before Recording
      reaper.Main_OnCommand(40363, 0) -- Show Metronome/Pre-roll settings
    else
      -- Metronome (Click track equivalent)
      if reaper.HasExtState("ATOM", "click_state") then
        ATOM.setButtonLED("dim", 105) --Click Button
        reaper.Main_OnCommand(41746, 0) -- Metronome Disable
        reaper.DeleteExtState("ATOM", "click_state", 1)
      else
        ATOM.setButtonLED("bright", 105) --Click Button
        reaper.Main_OnCommand(41745, 0) -- Metronome Enable
        reaper.SetExtState("ATOM", "click_state", "1", 0)
      end
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
    ATOM.setButtonLED("dim", 107)-- Record Dim
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
    if reaper.HasExtState("ATOM", "shift_state") then
      reaper.Main_OnCommand(40026, 0) -- Save current project
    else
      reaper.Main_OnCommand(1013, 0) -- Transport: Record
      ATOM.setButtonLED("bright", 107) -- Record Bright
      ATOM.setButtonLED("bright", 109) -- Play Bright
      ATOM.setButtonLED("dim", 111) -- Stop Dim
    end
  end
end

function ATOM.handlePad(pad, value)

  local devID

  if reaper.HasExtState("ATOM", "outID") then
    devID = tonumber(reaper.GetExtState("ATOM", "outID"))
  else
    -- Can't do anything without a valid outID
    return -1
  end
  
  if value == 127 then
    ATOM.setPadLED("press", 35+pad)    --
  else
    ATOM.setPadLED("release", 35+pad)    --
  end
end

function ATOM.setPadLED(mode, num)
  local devID
  if reaper.HasExtState("ATOM", "outID") then 
    devID = reaper.GetExtState("ATOM", "outID")  
  else
  -- This should never get hit since the existance of outID 
  -- should have checked before the call to this function. 
    ATOM.dbg_msg("\nATOM: Can't find outID")
    return -1
  end
  
  if reaper.HasExtState("ATOM", "padColor") then 
    colordata = reaper.GetExtState("ATOM", "padColor")  
    -- Load and execute a "chunk" that creates a table
    load(colordata)()    
  else
    ATOM.dbg_msg("\nATOM: Can't find padColor")
    return -1
  end
  
  if string.lower(mode) == "press" then
    reaper.StuffMIDIMessage(devID, 144, tonumber(num), 127)
    reaper.StuffMIDIMessage(devID, 145, tonumber(num), padColor[4]) -- Channel 2 (Red)
    reaper.StuffMIDIMessage(devID, 146, tonumber(num), padColor[5]) -- Channel 3 (Green)
    reaper.StuffMIDIMessage(devID, 147, tonumber(num), padColor[6]) -- Channel 4 (Blue)
    ATOM.dbg_msg("\nSet Pad to PRESS")
  elseif string.lower(mode) == "release" then
    reaper.StuffMIDIMessage(devID, 144, tonumber(num), 127)
    reaper.StuffMIDIMessage(devID, 145, tonumber(num), padColor[1]) -- Channel 2 (Red)
    reaper.StuffMIDIMessage(devID, 146, tonumber(num), padColor[2]) -- Channel 3 (Green)
    reaper.StuffMIDIMessage(devID, 147, tonumber(num), padColor[3]) -- Channel 4 (Blue)
    ATOM.dbg_msg("\nSet Pad to Release")
  else
    ATOM.dbg_msg("\nATOM:SetPadLED() - Invalid Mode Requested")
      return -1 -- invalid option
  end
end

--
-- Define the padColor table
-- Save padColor as a "chunk"
-- Call setPadLED to change the pad color
--
--
function ATOM.setPadColor(color)
  
  if string.lower(color) == 'red' then
    data = RED
  elseif string.lower(color) == '-red' then
    data = invRED
  elseif string.lower(color) == 'green' then
    data = GREEN
  elseif string.lower(color) == '-green' then
    data = invGREEN
  elseif string.lower(color) == 'blue' then
    data = BLUE
  elseif string.lower(color) == '-blue' then
    data = invBLUE
  elseif string.lower(color) == 'yellow' then
    data = YELLOW
  elseif string.lower(color) == '-yellow' then
    data = invYELLOW
  elseif string.lower(color) == 'orange' then
    data = ORANGE
  elseif string.lower(color) == '-orange' then
    data = invORANGE
  elseif string.lower(color) == 'purple' then
    data = PURPLE
  elseif string.lower(color) == '-purple' then
    data = invPURPLE
  elseif string.lower(color) == 'cyan' then
    data = CYAN
  elseif string.lower(color) == '-cyan' then
    data = invCYAN
  elseif string.lower(color) == 'white' then
    data = WHITE
  elseif string.lower(color) == '-white' then
    data = invWHITE
  elseif string.lower(color) == 'black' then
    data = [[ padColor = {0,0,0,0,0,0} ]]
  elseif string.lower(color) == 'user1' then
    data = USER1
  elseif string.lower(color) == 'user2' then
    data = USER2
  elseif string.lower(color) == 'user3' then
    data = USER3
  elseif string.lower(color) == 'user4' then
    data = USER4
  else
    ATOM.dbg_msg("\nATOM:SetPadColor() - Invalid Color")
    return -1 -- invalid option
  end
  
  reaper.SetExtState("ATOM", "padColor", data , 0)

  for pad = 1,16 do ATOM.setPadLED('release', 35+pad) end
  
end
--
function ATOM.setButtonLED(mode, num)
  local devID
  if reaper.HasExtState("ATOM", "outID") then 
    devID = reaper.GetExtState("ATOM", "outID")
    
  else
  -- This should never get hit since the existance of outID 
  -- should have checked before the call to this function. 
    ATOM.dbg_msg("\nATOM: Can't find outID")
    return -1
  end

  if string.lower(mode) == "bright" then
    reaper.StuffMIDIMessage(devID, 176, tonumber(num), 127)
    ATOM.dbg_msg("\nSet Button to Bright")
  elseif string.lower(mode) == "dim" then
    reaper.StuffMIDIMessage(devID, 176, tonumber(num), 0)
    ATOM.dbg_msg("\nNC Button to Dim")
  else
    ATOM.dbg_msg("\nATOM:SetButtonLED() - Invalid Mode Requested")
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

