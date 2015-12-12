import db_sqlite

proc echoBookmarkRow*(row: Row) =
    echo row[0], " ", row[1]

