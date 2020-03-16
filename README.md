# mserv-nim
An easy-ish way to manage a minecraft server

# Generated Help Page
```
This is a multiple-dispatch command.  Top-level --help/--help-syntax
is also available.  Usage is like:
    mserv {SUBCMD} [subcommand-opts & args]
where subcommand syntaxes are as follows:

  setup [optional-params] 
    Sets up all required server files by executing the server.jar file, and prompt user to accept the eula
  Options:
      -h, --help                      print this cligen-erated help
      --help-syntax                   advanced: prepend,plurals,..
      -a, --accept-eula  bool  false  Accepts the eula (fallback)
      -n, --no-download  bool  false  set no_download

  update [optional-params] 
    Update the server.jar file with a new version from the mojang download site
  Options:
      -h, --help         print this cligen-erated help
      --help-syntax      advanced: prepend,plurals,..

  run [optional-params] 
    Executes the server.jar file and starts the server with recommended settings
  Options:
      -h, --help                        print this cligen-erated help
      --help-syntax                     advanced: prepend,plurals,..
      -i=, --initRam=  string  "1024M"  set initRam
      -m=, --maxRam=   string  "1024M"  set maxRam
      -u, --usegui     bool    false    set usegui
      --isFirstRun     bool    false    set isFirstRun

  test [optional-params] 
  Options:
      -h, --help         print this cligen-erated help
      --help-syntax      advanced: prepend,plurals,..

  wipe [optional-params] 
    Wipe out the entire Server folder and re-run the setup folder
  Options:
      -h, --help         print this cligen-erated help
      --help-syntax      advanced: prepend,plurals,..```