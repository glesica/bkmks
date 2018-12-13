proc echoHelp*(exitCode: int = 0, exitAfter: bool = true) =
  echo "help"
  quit(exitCode)

proc echoVersion*(exitAfter: bool = true) =
  echo "version"
  quit(0)

proc echoActionError*() =
  echo "No valid action provided"
  echoHelp(1)

proc echoArgError*(arg: string) =
  echo "Invalid option or flag: ", arg
  echoHelp(1)
