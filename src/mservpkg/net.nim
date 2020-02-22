# Networking module for handling all network functionalities for this project

import strutils
import httpclient
import os
import asyncdispatch
import math

# progress reporting for download
proc progressChanged(total, progress, speed: BiggestInt) {.async.} =
    # Calculate the percentage
    var perc = (progress.int / total.int) * 100
    echo("Downloaded ", perc.floor.int, "%")
    echo("Current rate: ", speed div 1000, "kb/s")

# rough method of extracting file name from url string
proc extractFilename(url:string): string =
    var name = url.split('/')
    return name[name.high]

# Check to make sure that the file made the journey safely
proc checkDLSuccess*(fileDir:string, fileUrl:string): bool = 
    if fileExists(fileDir) and (fileDir.split)[fileDir.split.high] == extractFilename(fileUrl):
        return true
    else:
        return false

# roughly Download file information from url
proc downloadFromUrl(url:string, outDir:string="") {.async.} =

    var fullDir: string = ""
    var derivedFileame: string = extractFilename(url)

    if outDir is "":
        fullDir = os.joinPath(os.getCurrentDir(), derivedFileame)
    else:
        fullDir = os.joinPath(outDir, derivedFileame)
    # Download the file from the internet
    var dlClient = newAsyncHttpClient()
    dlClient.onProgressChanged = progressChanged
    await dlClient.downloadFile(url, fullDir)

proc dlFile*(url: string, outDir = "") =
    waitFor(downloadFromUrl(url, outDir))
    