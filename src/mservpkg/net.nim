# Networking module for handling all network functionalities for this project

import strutils
import httpclient
import os
import asyncdispatch

# progress reporting for download
proc progressChanged(total, progress, speed: BiggestInt) {.async.} =
    # Calculate the percentage
    var perc = (progress.int / total.int) * 100
    echo("Downloaded ", repeat("=", (perc/10).toInt()), " <", perc.toInt(), "%> ", speed div 1000, "kb/s")

proc getFullFileDir(url:string, directory=""): string =
    var derivedName = extractFilename(url)
    var finalDir = ""
    if directory == "":
        finalDir = joinPath(os.getCurrentDir(), derivedName)
    else:
        finalDir = joinPath(directory, derivedName)

    return finalDir

# rough method of extracting file name from url string
proc extractFilename(url:string): string =
    var name = url.split('/')
    return name[name.high]

# Check to make sure that the file made the journey safely
proc checkDLSuccess(fileDir:string, fileUrl:string): bool = 
    var fullDir = getFullFileDir(fileUrl, fileDir)
    if fileExists(fullDir) and fullDir.split('/')[fullDir.split('/').high] == extractFilename(fileUrl):
        return true
    else:
        return false

# roughly Download file information from url
proc downloadFromUrl(url:string, outDir:string="") {.async.} =

    var fullDir = getFullFileDir(url, outDir)
    # Download the file from the internet
    var dlClient = newAsyncHttpClient()
    dlClient.onProgressChanged = progressChanged
    await dlClient.downloadFile(url, fullDir)

# Little absraction layer for the download (This is the method that should be used)
proc dlFile*(url: string, outDir = ""): bool =
    waitFor(downloadFromUrl(url, outDir))
    return checkDLSuccess(outDir, url)
    