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
import tables
import rdstdin

# Global vars for use throughout the program
var serverNames = initTable[string, string]()
var selectedServer:string
let serverUrl = "https://www.minecraft.net/en-us/download/server/"

proc extractServerUrl(url=serverUrl): string = 
  var pageXml = scrapePage(url)
  for links in pageXml.findAll("a"):
    if links.attrs.hasKey "href":
        let (_, _, ext) = splitFile(links.attrs["href"])
        if cmpIgnoreCase(ext, ".jar") == 0:
          logInfo("Found file at: " & links.attrs["href"])
          return links.attrs["href"]


proc getValidServers():seq[string] = 
  ## Walk through current working directory and see if valid servers exist

  # create a mutable list that can hold all valid server directories
  var validServers:seq[string]

  # iterate over the current working directory for sub directories
  for kindRoot, pathRoot in walkDir(os.getCurrentDir()):
    # if subdirectory found, check to see if it has key server files
    if kindRoot == pcDir:
      for kindChild, pathChild in walkDir(pathRoot):
        # if these filenames and directories exist, add the path to the list
        if pathChild.contains("server.jar") or pathChild.contains("eula.txt"):
          validServers.add(pathRoot)
          break
  return validServers

proc populateServerMap() = 
  for server in getValidServers():
    serverNames[extractFilename(server)] = server

proc acceptEula() = 
  ## Locates the eula.txt file and changes the acceptance text from false to true
  fileSearchAndRepl(joinPath(selectedServer, "eula.txt"), "eula=false", "eula=true")

# Executes the server with the reccommended settings (can be changed using params)
proc run(initRam="1024M", maxRam="1024M", usegui=false, isFirstRun=false, specificServer=""): int = 
  ## Executes the server.jar file and starts the server with recommended settings
  
  var guiFlag = case usegui:
    of false:
      "nogui"
    else:
      ""

  populateServerMap()

  if specificServer != "":
    logInfo("Generating Needed Files")
    var joined = joinPath(specificServer, "server.jar")
    setCurrentDir(specificServer)
    var extStat = execShellCmd(fmt"java -Xms{initRam} -Xmx{maxRam} -jar {joined} {guiFlag}")
    return extStat

  # Have the user select what server they'd like to use
  var servers = initTable[string, string]()
  var serverCounter = 0
  for item in serverNames.keys:
    serverCounter += 1
    servers[serverCounter.intToStr()] = item

  logBlue "Select your server number:\n"
  for serverEntry in servers.keys:
    echo style(serverEntry, termBold & termBlue), " ", style(servers[serverEntry], termBold & termWhite)

  selectedServer = serverNames[servers[readLineFromStdin("")]]
  # combines the path of the server directory with the server.jar executable
  var joinedServerExe = joinPath(selectedServer, "server.jar")


  if selectedServer in serverNames[extractFilename(selectedServer)]:
    logInfo("Executing server.jar")
    setCurrentDir(selectedServer)
    var extStat = execShellCmd(fmt"java -Xms{initRam} -Xmx{maxRam} -jar {joinedServerExe} {guiFlag}")
    return extStat
  else:
    raise newException(IOError, style("Server does not exist", termBold & termRed))

# main process for routing commands to the API
proc setup(accept_eula=false, no_download=false) = 
  ## Sets up all required server files by executing the server.jar file, and prompt user to accept the eula
  
  # Asks the user what they would like their server to be called
  echo style("What would you like your server to be called? (no spaces please)\n", termBold, termYellow)
  var usrServerName = readLine(stdin)
  createDir(joinPath(getCurrentDir(), usrServerName))
  selectedServer = joinPath(getCurrentDir(), usrServerName)

  # Subcommand for if the user only wants to accept the eula (maybe they accidentally hit no)
  if accept_eula:
    acceptEula()
    return

  # if no_download flag is set, the program will not download the server.jar but will continue the rest of the steps
  if not no_download:
    dlFile(extractServerUrl(), selectedServer) # Download the server.jar file
  else:
    logInfo("no_download flag set. File will not be downloaded")

  # generate the server files using the above run command 
  discard run(isFirstRun=true, specificServer=selectedServer)

  echo style("\nWould you like to accept the Minecraft Server EULA? (y/N):", termYellow & termBold)
  # Get user input on whether they would like to accept the eula
  var usrIn = readLine(stdin)
  if usrIn.toLower() == "y":
    acceptEula()
    echo style("EULA Accepted!", termBold & termGreen)
  else:
    echo style("You didn't accept the EULA. Nothing else to do.", termBold & termYellow)

# Deletes the server.jar file and downloads the new one from the url
#TODO - error handling and better cases (to avoid uneccessary downloads)
proc update() = 
  ## Update the server.jar file with a new version from the mojang download site
  logInfo("Updating server executable")
  removeFile(joinPath(selectedServer, "server.jar")) # Delete the server file
  dlFile(extractServerUrl(), selectedServer) # Download the new server.jar file

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
    removeDir(selectedServer)
    echo style("Would you like to re-generate server files? (Y/n)", termBold & termYellow)
    usrin = readLine stdin
    if usrin.toLower == "y" or usrin == "":
      setup()
      echo style("Files Generated", termYellow & termBold)
    else:
      echo style("Files Not Generated", termYellow & termBold)
    echo style("Wipe Completed!", termGreen & termBold)

# proc for testing out whatever needs to be tested. Throwaway
proc test() =
  return

when isMainModule:
  dispatchMulti([setup, help={"accept-eula": "Accepts the eula (fallback)"}], [update], [run], [test], [wipe])
