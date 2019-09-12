
-- This code needs to be at the top of every ATOM script.
-- Otherwise, we won't be able to find our support module. 
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = path .. "?.lua"
atom = require("ATOM")

atom.debug("disable") -- Turn OFF debug messages

if reaper.HasExtState("ATOM", "outID") then -- Should have been set by find() 
  target_outID = tonumber(reaper.GetExtState("ATOM", "outID"))
  atom.dbg_msg("\ntarget_outID: " .. tostring(target_outID))
  atom.nc_mode("disable")
else   
  atom.dbg_msg("\nERROR: Unable to locate an ATOM Pad Controller\n") 
end



