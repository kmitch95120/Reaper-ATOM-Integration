-- This code needs to be at the top of every ATOM script.
-- Otherwise, we won't be able to find our support module. 
package.path = reaper.GetResourcePath() .. "/Scripts/ATOM/?.lua"
atom = require("ATOM")
atom.nc_mode("disable")



