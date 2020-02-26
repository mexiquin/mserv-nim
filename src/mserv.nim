# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import mservpkg/net, mservpkg/fileIO, mservpkg/logSimp
import os
import cligen
import strformat
import strutils
import termstyle

# Global vars for use throughout the program
let binDir = os.getAppDir()
let serverUrl = "https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar"

# TODO - check if server files already generated
#proc checkServerExists()

# TODO - check if java is installed
#proc checkJavaInstalled()

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

proc acceptEula() = 
  fileSearchAndRepl(joinPath(binDir, "Server", "eula.txt"), "eula=false", "eula=true")

# Executes the server with the reccommended settings (can be changed using params)
proc run(initRam="1024M", maxRam="1024M", usegui=false): int = 
  logInfo("Executing server.jar")
  var guiFlag = case usegui:
    of false:
      "nogui"
    else:
      ""
  return execShellCmd(fmt"java -Xms{initRam} -Xmx{maxRam} -jar server.jar {guiFlag}")

# main process for routing commands to the API
proc setup(accept_eula=false, no_download=false) = 
  # Subcommand for if the user only wants to accept the eula (maybe they accidentally hit no)
  if accept_eula:
    acceptEula()
    return

  discard checkServerFolder() # make sure the server directory exists

  # if no_download flag is set, the program will not download the server.jar but will continue the rest of the steps
  if not no_download:
    dlFile(serverUrl, joinPath(binDir, "Server")) # Download the server.jar file
  else:
    logInfo("no_download flag set. File will not be downloaded")

  setCurrentDir(joinPath(binDir, "Server")) # Set the working dir to the server dir. This makes sure files are executed in the right place
  logInfo("Generating Server Files...")
  discard run() # execute the server once to generate the directory structure
  setCurrentDir(ParDir) # Reset the working directory to where it was before (where the binary is located)

  echo style("\nWould you like to accept the Minecraft Server EULA? (Y/n):", termYellow & termBold)
  # Get user input on whether they would like to accept the eula
  var usrIn = readLine(stdin)
  if usrIn.toLower() == "y" or usrIn == "":
    acceptEula()
    echo style("EULA Accepted!", termBold & termGreen)
  else:
    echo style("You didn't accept the EULA. Nothing else to do.", termBold & termYellow)

# Deletes the server.jar file and downloads the new one from the url
#TODO
proc update() = 
  echo "update function"

# Acts as a hard restart. Deletes all server files, redownloads a new server file and rerun's the setup
#TODO
proc wipe() = 
  echo "wipe function"


when isMainModule:
  dispatchMulti([setup, help={"accept-eula": "Accepts the eula (fallback)"}], [update], [run])
