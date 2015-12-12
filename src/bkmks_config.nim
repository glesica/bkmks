import os

const DbPathEnv = "BKMKS_DB_PATH"

proc defaultDbPath(): string =
    getHomeDir() / ".bkmksdb"

proc getDbPath*(): string =
    if existsEnv(DbPathEnv):
        getEnv(DbPathEnv)
    else:
        defaultDbPath()

