import
    db_sqlite,
    uri,
    strutils

import
    bkmks_models

proc insertBkmk*(db: DbConn,
                 url: string,
                 tags: seq[string]) =
    ## Insert a new bookmark into the database with the given
    ## URL and tags.
    let hostname = parseUri(url).hostname
    let domain =
        if startsWith(hostname, "www."):
            replace(hostname, "www.", "")
        else:
            hostname
    db.exec(sql"BEGIN")
    db.exec(sql"""
        INSERT OR IGNORE INTO
        urls (content, domain) VALUES (?, ?)""",
        url, domain)
    let id = parseInt(db.getValue(
        sql"SELECT id FROM urls WHERE content = ?", url))
    for tag in tags:
        # Remove commas because we use those in the query to
        # fetch bookmarks by tags.
        let cleanTag = tag.replace(",", "")
        db.exec(
            sql"INSERT OR IGNORE INTO tags (value, url_id) VALUES (?, ?)",
            cleanTag, id)
    db.exec(sql"COMMIT")
