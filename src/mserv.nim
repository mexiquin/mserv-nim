# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import mservpkg/net
import os
import parseopt2

# check to see if ./Server directory exists within the binary's scope
proc checkServerFolder(): bool = 
  if dirExists(os.joinPath(os.getAppDir(), "Server")):
    return true
  else:
    os.createDir(os.joinPath(os.getAppDir(), "Server"))
    if checkServerFolder():
      return true
    else:
      raise newException(OSError, "Directory creation failed")

# Entry point of the program
when isMainModule:
  let binDir = os.getAppDir()
  let serverUrl = "https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar"

  # TODO create argument parser to grab the commandline arguments
