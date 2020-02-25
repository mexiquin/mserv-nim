import strutils

# Some abstraction layers for managing files and data within files

# Open, search for match, and replace string within file
proc fileSearchAndRepl*(fileDir:string, keyword:string, replacement:string) =
    echo "Directory: ", fileDir 
    fileDir.writeFile(fileDir.readFile.replace(keyword, replacement))