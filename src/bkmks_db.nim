import
    db_sqlite,
    uri,
    strutils

import
    bkmks_util

proc initDb(db: DbConn) =
    db.exec(sql"PRAGMA foreign_keys = ON")
    db.exec(sql"""
        CREATE TABLE IF NOT EXISTS urls (
            id      INTEGER PRIMARY KEY,
            content TEXT UNIQUE NOT NULL,
            domain  TEXT NOT NULL)""")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS urls_domain_idx ON urls(domain)")
    db.exec(sql"BEGIN")
    db.exec(sql"""
        CREATE TABLE IF NOT EXISTS tags (
            value VARCHAR(64) NOT NULL,
            url_id INTEGER NOT NULL REFERENCES urls(id)
                ON UPDATE CASCADE ON DELETE CASCADE)""")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS tags_value_idx ON tags(value)")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS tags_url_id_idx ON tags(url_id)")
    db.exec(sql"""
        CREATE UNIQUE INDEX IF NOT EXISTS
            tags_join_idx ON tags(value, url_id)""")
    db.exec(sql"COMMIT")

proc openDb*(path: string): DbConn =
    let db = open(path, nil, nil, nil)
    initDb(db)
    return db

proc addBookmark*(db: DbConn, url: string, tags: seq[string]) =
    let hostname = parseUri(url).hostname
    let domain =
        if startsWith(hostname, "www."):
            replace(hostname, "www.", "")
        else:
            hostname
    db.exec(sql"""
        INSERT OR IGNORE INTO
        urls (content, domain) VALUES (?, ?)""",
        url, domain)
    let id = parseInt(db.getValue(
        sql"SELECT id FROM urls WHERE content = ?", url))
    db.exec(sql"BEGIN")
    for tag in tags:
        db.exec(
            sql"INSERT OR IGNORE INTO tags (value, url_id) VALUES (?, ?)",
            tag, id)
    db.exec(sql"COMMIT")

proc deleteBookmarkByUrl*(db: DbConn, url: string) =
    db.exec(sql"""
        DELETE FROM urls WHERE content = ?""", url)

proc deleteBookmarkById*(db: DbConn, id: int) =
    db.exec(sql"""
        DELETE FROM urls WHERE id = ?""", id)

proc deleteBookmarksByDomain*(db: DbConn, domain: string) =
    db.exec(sql"""
        DELETE FROM urls WHERE domain = ?""", domain)

proc deleteBookmarksByTags*(db: DbConn, tags: seq[string]) =
    let query = sql"""
        SELECT"""

proc echoBookmarks*(db: DbConn, limit: int = 100) =
    let query = sql"""
        SELECT urls.id, urls.content FROM urls
        LIMIT ?"""
    for row in db.rows(query, limit):
        echoBookmarkRow(row)

proc echoBookmarksForDomain*(db: DbConn, domain: string) =
    let query = sql"""
        SELECT urls.id, urls.content FROM urls
        WHERE urls.domain = ?"""
    for row in db.rows(query, domain):
        echoBookmarkRow(row)

proc echoBookmarksForTag*(db: DbConn, tag: string) =
    let query = sql"""
        SELECT urls.id, urls.content FROM urls JOIN tags ON urls.id = tags.url_id
        WHERE tags.value = ?"""
    for row in db.rows(query, tag):
        echoBookmarkRow(row)

