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
  local NCcommand = 143 -- Channel 16 Note Off
  local NCnote = 0 
  local Enable = 127
  local Disable = 0 

-- First we need to get the outID for the ATOM
  if reaper.HasExtState("ATOM", "outID") then 
    devID = reaper.GetExtState("ATOM", "outID")
  else
  -- This should never get hit since the existance of outID 
  -- should have checked before the call to this function. 
    ATOM.message("\nATOM:nc_mode() - Can't find outID")
    return -1
  end
    
  if string.lower(op) == "enable" then
    reaper.StuffMIDIMessage(devID, NCcommand, NCnote, Enable)
    ATOM.dbg_msg("\nNC Mode set to Enable")
  elseif string.lower(op) == "disable" then
    reaper.StuffMIDIMessage(devID, NCcommand, NCnote, Disable)
    ATOM.dbg_msg("\nNC Mode set to Disable")
  else
    ATOM.message("\nATOM:nc_mode() - Invalid Operation Requested")
      return -1 -- invalid option
  end
end

return ATOM

