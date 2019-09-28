--
-- This script needs to be bound to MIDI Channel 1, CC 109
--
-- This code needs to be at the top of every ATOM script.
-- Otherwise, we won't be able to find our support module. 
package.path = reaper.GetResourcePath() .. "/Scripts/ATOM/?.lua"
atom = require("ATOM")

is_new,filename,sectionID,cmdID,mode,resolution,value = reaper.get_action_context()

if is_new then atom.handleRecord(value) end

