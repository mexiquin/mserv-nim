# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import mservpkg/net, mservpkg/fileIO, mservpkg/logSimp
import os
import cligen
import strformat
import strutils
import termstyle
import xmltree
import strtabs

# Global vars for use throughout the program
let binDir = os.getAppDir()
let serverDir = joinPath(binDir, "Server")
let serverUrl = "https://www.minecraft.net/en-us/download/server/"

proc extractServerUrl(url=serverUrl): string = 
  var pageXml = scrapePage(url)
  for links in pageXml.findAll("a"):
    if links.attrs.hasKey "href":
        let (_, _, ext) = splitFile(links.attrs["href"])
        if cmpIgnoreCase(ext, ".jar") == 0:
          logInfo("Found file at: " & links.attrs["href"])
          return links.attrs["href"]

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

# TODO - check if server files already generated
proc isServerValid(): bool = 
  if checkServerFolder() and dirExists(joinPath(serverDir, "logs")) and existsFile(joinPath(serverDir, "eula.txt")) and existsFile(joinPath(serverDir, "server.properties")):
    return true
  else:
    return false

proc acceptEula() = 
  fileSearchAndRepl(joinPath(binDir, "Server", "eula.txt"), "eula=false", "eula=true")

# Executes the server with the reccommended settings (can be changed using params)
proc run(initRam="1024M", maxRam="1024M", usegui=false, isFirstRun=false): int = 
  ## Executes the server.jar file and starts the server with recommended settings
  if isServerValid() or isFirstRun:
    logInfo("Executing server.jar")
    var guiFlag = case usegui:
      of false:
        "nogui"
      else:
        ""
    setCurrentDir(joinPath(binDir, "Server")) # Set the working dir to the server dir. This makes sure files are executed in the right place
    var extStat = execShellCmd(fmt"java -Xms{initRam} -Xmx{maxRam} -jar server.jar {guiFlag}")
    setCurrentDir(ParDir) # Reset the working directory to where it was before (where the binary is located)
    return extStat
  else:
    raise newException(IOError, style("Server folder does not exist", termBold & termRed))

# main process for routing commands to the API
proc setup(accept_eula=false, no_download=false) = 
  ## Sets up all required server files by executing the server.jar file, and prompt user to accept the eula

  # Subcommand for if the user only wants to accept the eula (maybe they accidentally hit no)
  if accept_eula:
    acceptEula()
    return

  discard checkServerFolder() # make sure the server directory exists

  # check to make sure this operation hasn't already been done
  if fileExists(joinPath(serverDir, "server.jar")):
    logInfo("Server already setup.")
    echo "\nYou can run the server using the command: ", style("mserv run", termBold & termGreen)
    return

  # if no_download flag is set, the program will not download the server.jar but will continue the rest of the steps
  if not no_download:
    dlFile(extractServerUrl(), joinPath(binDir, "Server")) # Download the server.jar file
  else:
    logInfo("no_download flag set. File will not be downloaded")

  logInfo("Generating Server Files...")
  discard run(isFirstRun=true) # execute the server once to generate the directory structure

  echo style("\nWould you like to accept the Minecraft Server EULA? (Y/n):", termYellow & termBold)
  # Get user input on whether they would like to accept the eula
  var usrIn = readLine(stdin)
  if usrIn.toLower() == "y" or usrIn == "":
    acceptEula()
    echo style("EULA Accepted!", termBold & termGreen)
  else:
    echo style("You didn't accept the EULA. Nothing else to do.", termBold & termYellow)

# Deletes the server.jar file and downloads the new one from the url
#TODO - error handling and better cases (to avoid uneccessary downloads)
proc update() = 
  ## Update the server.jar file with a new version from the mojang download site
  logInfo("Updating server executable")
  removeFile(joinPath(binDir, "Server", "server.jar")) # Delete the server file
  dlFile(extractServerUrl(), joinPath(binDir, "Server")) # Download the new server.jar file

# Acts as a hard restart. Deletes all server files, redownloads a new server file and rerun's the setup
#TODO
proc wipe() = 
  ## Wipe out the entire Server folder and re-run the setup folder

  # check to make sure the user is ABSOLUTELY SURE they want to do this
  echo style("Are you sure you want to wipe? There's no going back! (N/y)", termRed & termBold)
  var usrin = readLine stdin
  if usrin.toLower != "y":
    echo style("Wipe Cancelled!", termBold & termGreen)
  else:
    removeDir(serverDir)
    echo style("Would you like to re-generate server files? (Y/n)", termBold & termYellow)
    usrin = readLine stdin
    if usrin.toLower == "y" or usrin == "":
      setup()
      echo style("Wipe Completed!", termGreen & termBold)
    else:
      echo style("Files Not Generated", termYellow & termBold)
      echo style("Wipe Completed!", termGreen & termBold)

# proc for testing out whatever needs to be tested. Throwaway
proc test() =
  return

when isMainModule:
  dispatchMulti([setup, help={"accept-eula": "Accepts the eula (fallback)"}], [update], [run], [test], [wipe])
