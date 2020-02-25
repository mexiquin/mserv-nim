# Networking module for handling all network functionalities for this project

import strutils
import httpclient
import os
import asyncdispatch
import terminal

# progress reporting for download
proc progressChanged(total, progress, speed: BiggestInt) {.async.} =
    # Calculate the percentage
    var perc = (progress.int / total.int) * 100
    echo("Downloaded ", repeat("=", (perc/10).toInt()), " <", perc.toInt(), "%> ", speed div 1000, "kb/s")

# Combines a directory and a file url to become a file path
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
proc isDLSuccess*(fileDir:string, fileUrl:string): bool = 
    var fullDir = getFullFileDir(fileUrl, fileDir)
    if fileExists(fullDir) and fullDir.split('/')[fullDir.split('/').high] == extractFilename(fileUrl):
        return true
    else:
        return false

# roughly Download file information from url
proc downloadFromUrl(url:string, outDir:string="") {.async.} =

    var fullDir = getFullFileDir(url, outDir)
    echo fullDir
    # Download the file from the internet
    var dlClient = newAsyncHttpClient()
    try:
        dlClient.onProgressChanged = progressChanged
        await dlClient.downloadFile(url, fullDir)
    except:
        raise

# Little absraction layer for the download (This is the method that should be used)
proc dlFile*(url: string, outDir = "") =
    waitFor(downloadFromUrl(url, outDir))
