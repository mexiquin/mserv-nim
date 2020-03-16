# Networking module for handling all network functionalities for this project

import strutils
import httpclient
import os
import asyncdispatch
import termstyle
import terminal
import strformat 
import htmlparser
import xmltree
import logSimp

# progress reporting for download
proc progressChanged(total, progress, speed: BiggestInt) {.async.} =
    # Calculate the percentage
    var perc = (progress.int / total.int) * 100
    let dl = style("Downloading", termGreen & termBold)
    let prgrs = repeat("=", (perc/4).toInt())
    let dlspd = speed div 1000
    stdout.eraseLine
    stdout.write(fmt"{dl} [{alignString(prgrs, 25)}] {perc.toInt()}% {dlspd} kb/s")
    stdout.flushFile

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
    ## Checks if the download of the file was successful
    logInfo(fmt"Verifying dl from {fileUrl} to {fileDir}")
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
    try:
        dlClient.onProgressChanged = progressChanged
        await dlClient.downloadFile(url, fullDir)
    except:
        raise
    
    echo "\n" # when done, plop down a newline so that the progress bar doesn't mush together with other text

# Little absraction layer for the download (This is the method that should be used)
proc dlFile*(url: string, outDir = "") =
    ## Download a file from a url to the computer. If output directory not specified, will download to working directory
    waitFor(downloadFromUrl(url, outDir))

#TODO webscraping to find downloadable files
proc scrapePage*(url:string): XmlNode = 
    ## Function for web scraping and gathering info about a webpage
    logInfo(fmt"Scraping {url}")
    var client = newHttpClient()
    return parseHtml(client.getContent(url))
