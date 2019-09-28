package.path = reaper.GetResourcePath() .. "/Scripts/ATOM/?.lua"
atom = require("ATOM")
atom.nc_mode("enable")
atom.start_polling()

