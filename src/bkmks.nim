import
    db_sqlite,
    parseopt2,
    strutils

import
    bkmks_config,
    bkmks_db

type
    Action = enum
        none,
        addBkmk,
        deleteBkmk

proc echoHelp() =
    echo "help message"

proc echoVersion() =
    echo "version message"

proc echoArgError(arg: string) =
    echo "Invalid argument: ", arg
    echoHelp()

let db = openDb(getDbPath())

var
    action: Action = none
    urls: seq[string] = @[]
    tags: seq[string] = @[]

for kind, key, val in getopt():
    case kind
    of cmdArgument:
        urls.add(key)
    of cmdLongOption, cmdShortOption:
        case key
        of "help", "h": echoHelp()
        of "version", "v": echoVersion()
        of "tag", "t": tags.add(val)
        of "add", "a": action = addBkmk
        of "delete", "d": action = deleteBkmk
        else: echoArgError(key)
    of cmdEnd: discard

case action
of none:
    discard
of addBkmk:
    for url in urls:
        addBookmark(db, url, tags)
of deleteBkmk:
    for url in urls:
        deleteBookmarkByUrl(db, url)

db.close()

