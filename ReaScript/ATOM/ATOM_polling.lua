--
-- This script runs in the background in deferred mode, polls
-- certain Reaper states, and unpdates the ATOM accordingly. 
--
-- This code needs to be at the top of every ATOM script.
-- Otherwise, we won't be able to find our support module. 
package.path = reaper.GetResourcePath() .. "/Scripts/ATOM/?.lua"
atom = require("ATOM")
lasttime=os.time()

function main()       
    local curr_playstate
    local prev_playstate
    local newtime=os.time()
  
    if newtime-lasttime >= 1 then  -- Run once a second (Thanks schwa!)
        lasttime=newtime
        curr_playstate = reaper.GetPlayState()
        --reaper.ShowConsoleMsg("\nCurrent PlayState: " .. tostring(curr_playstate) .. " - ")
        if reaper.HasExtState("ATOM", "play_state") then
            prev_playstate = tonumber(reaper.GetExtState("ATOM", "play_state"))
        else
            prev_playstate = 0 -- XXX: Assume Stopped. This might not be a good idea but for now...
        end
        
        if curr_playstate ~= prev_playstate then 
            if curr_playstate == 0 then -- Stopped
                atom.setButtonLED("dim", 107) -- Record Dim
                atom.setButtonLED("dim", 109) -- Play Dim
                atom.setButtonLED("bright", 111) -- Stop Bright
            elseif curr_playstate == 1 then -- Playing
                atom.setButtonLED("bright", 109) -- Play Bright
                atom.setButtonLED("dim", 111) -- Stop Dim
                atom.setButtonLED("dim", 107) -- Record Dim
            elseif curr_playstate == 2 then -- Paused
                -- XXX: Same as play for now. 
                atom.setButtonLED("bright", 109) -- Play Bright
                atom.setButtonLED("dim", 107) -- Record Dim
                atom.setButtonLED("dim", 111) -- Stop Dim
        -- WHAT IS 3 AND 4?
            elseif curr_playstate == 5 then -- Recording    
                atom.setButtonLED("bright", 107) -- Record Bright
                atom.setButtonLED("bright", 109) -- Play Bright
                atom.setButtonLED("dim", 111) -- Stop Dim
            end
        reaper.SetExtState("ATOM", "play_state", tostring(cur_playstate), 0)
        end
  
        -- Check Repeat State
        if reaper.GetSetRepeat(-1) == 0 then
            atom.setPlayGreen() -- if Repeat OfF
        else
            atom.setPlayBlue() -- If Repeat On
        end

    end -- Yimer End 
    
    reaper.defer(main)  

end -- Function End

reaper.defer(main)
