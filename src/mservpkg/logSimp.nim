# Simple logging for printing info to the console
import termstyle, strformat

# Print Info log
proc logInfo*(message:string) = 
    ## Print a message to the console with neutral info coloring
    echo style("[INFO]: ", termBold & termWhite), message

proc logWarning*(message:string) = 
    ## Print a message to the console with yellow warning coloring
    echo style("[WARN]: ", termBold & termYellow), message

proc logError*(message:string) = 
    ## Print a message to the console with red error coloring
    echo style("[ERROR]: ", termBold & termRed), message

proc logGreen*(message:string) = 
    ## Print a message to the console with red error coloring
    echo style(fmt"{message}", termBold & termGreen)

proc logBlue*(message:string) = 
    ## Print a message to the console with red error coloring
    echo style(fmt"{message}", termBold & termBlue)

proc txtGreen*(message:string): string = 
    ## Print a message to the console with red error coloring
    return style(fmt"{message}", termBold & termGreen)

proc txtBlue*(message:string): string = 
    ## Print a message to the console with red error coloring
    return style(fmt"{message}", termBold & termBlue)