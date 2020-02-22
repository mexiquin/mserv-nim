# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import mservpkg/net

# TEMP - Test if the download functions work
when isMainModule:
  let serverUrl = "https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar"
  echo net.downloadFromUrl(serverUrl, "")
