# Networking module for handling all network functionalities for this project

import strutils
import httpclient
import os
import asyncdispatch

# progress reporting for download
proc onProgressChanged(total, progress, speed: BiggestInt) {.async.} =
    echo("Downloaded ", progress, " of ", total)
    echo("Current rate: ", speed div 1000, "kb/s")

# rough method of extracting file name from url string
proc extractFilename(url:string): string =
    var name = url.split('/')
    return name[name.high]

# Check to make sure that the file made the journey safely
proc checkDLSuccess(fileDir:string, fileUrl:string): bool = 
    if fileExists(fileDir) and (fileDir.split)[fileDir.split.high] == extractFilename(fileUrl):
        return true
    else:
        return false

# roughly Download file information from url
proc downloadFromUrl*(url:string, outDir:string=""): bool =

    var fullDir: string = ""
    var derivedFileame: string = extractFilename(url)

    if outDir is "":
        fullDir = os.joinPath(os.getCurrentDir(), derivedFileame)
    else:
        fullDir = os.joinPath(outDir, derivedFileame)
    # Download the file from the internet
    var dlClient = newAsyncHttpClient()
    dlClient.onProgressChanged = onProgressChanged
    await dlClient.downloadFile(url, fullDir)

    return checkDLSuccess(fullDir, url)
    