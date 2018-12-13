import
    db_sqlite,
    parseopt,
    strutils

import
    bkmks_action,
    bkmks_config,
    bkmks_db,
    bkmks_db_delete,
    bkmks_db_fetch,
    bkmks_db_insert,
    bkmks_help,
    bkmks_parse,
    bkmks_show

let db = openDb(getDbPath())

var parser = initOptParser(shortNoVal = {
    'd',
    'h',
    'i',
    't',
    'v',
}, longNoVal = @[
    "domain",
    "help",
    "id",
    "tag",
    "version",
])

var
    action: Action = actionNone
    domain: string = ""
    ids: seq[int] = @[]
    tags: seq[string] = @[]
    urls: seq[string] = @[]

for kind, key, val in parser.getopt():
    case kind
    of cmdArgument:
        case key
        of "add": action = actionAddBkmk
        of "delete": action = actionDeleteBkmk
        of "show": action = actionShowBkmk
        else: urls.add(key)
    of cmdLongOption, cmdShortOption:
        case key
        of "domain", "d": domain = val
        of "help", "h": echoHelp()
        of "id", "i": ids.parseIds(val)
        of "tag", "t": tags.parseTags(val)
        of "version", "v": echoVersion()
        else: echoArgError(key)
    of cmdEnd: discard

case action
of actionNone:
    echoActionError()
of actionAddBkmk:
    for url in urls:
        db.insertBkmk(url, tags)
of actionDeleteBkmk:
    if domain != "":
        db.deleteBkmks(domain)
    for id in ids:
        db.deleteBkmk(id)
    if tags.len > 0:
        db.deleteBkmks(tags)
    for url in urls:
        db.deleteBkmk(url)
of actionShowBkmk:
    let bs = db.fetchBkmks()
    bs.showBkmks()

db.close()
quit(0)
