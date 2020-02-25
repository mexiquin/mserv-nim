# Package

version       = "0.1.0"
author        = "Quinton Jasper"
description   = "A simple to use helper for managing a Minecraft Server"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
installExt    = @["nim"]
bin           = @["mserv"]



# Dependencies

requires "nim >= 1.0.6"
requires "cligen"
requires "termstyle"
