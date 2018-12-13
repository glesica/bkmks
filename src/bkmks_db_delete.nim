import
    db_sqlite

proc deleteBkmk*(db: DbConn, url: string) =
    ## Delete a bookmark and all of its tags by its URL.
    db.exec(sql"DELETE FROM urls WHERE content = ?", url)

proc deleteBkmk*(db: DbConn, id: int) =
    ## Delete a bookmark and all of its tags by its ID.
    db.exec(sql"DELETE FROM urls WHERE id = ?", id)

proc deleteBkmks*(db: DbConn, domain: string) =
    ## Delete all bookmarks (and their tags) that reference
    ## the given domain.
    db.exec(sql"DELETE FROM urls WHERE domain = ?", domain)

# TODO: Decide on the semantics here
proc deleteBkmks*(db: DbConn, tags: seq[string]) =
    let query = sql"""SELECT"""
