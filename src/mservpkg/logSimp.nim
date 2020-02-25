# Simple logging for printing info to the console
import termstyle

# Print Info log
proc logInfo*(message:string) = 
    echo style("[INFO]: ", termBold & termYellow), message

proc logError*(message:string) = 
    echo style("[ERROR]: ", termBold & termRed), message
