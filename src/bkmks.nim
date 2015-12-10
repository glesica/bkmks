import db_sqlite, strutils

let db = open("mytest.db", nil, nil, nil)

proc initDB() =
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
            url_id INTEGER NOT NULL,
            FOREIGN KEY(url_id) REFERENCES urls(id))""")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS tags_value_idx ON tags(value)")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS tags_url_id_idx ON tags(url_id)")
    db.exec(sql"""
        CREATE UNIQUE INDEX IF NOT EXISTS
            tags_join_idx ON tags(value, url_id)""")
    db.exec(sql"COMMIT")

proc addBookmark(url: string, tags: seq[string]) =
    db.exec(sql"""
        INSERT OR IGNORE INTO
        urls (content, domain) VALUES (?, ?)""",
        url, "fakedomain.com")
    let id = parseInt(db.getValue(
        sql"SELECT id FROM urls WHERE content = ?", url))
    db.exec(sql"BEGIN")
    for tag in tags:
        db.exec(
            sql"INSERT OR IGNORE INTO tags (value, url_id) VALUES (?, ?)",
            tag, id)
    db.exec(sql"COMMIT")

proc echoBookmarkRow(row: Row) =
    echo row[0], " ", row[1]

proc echoBookmarks(limit: int = 100) =
    let query = sql"""
        SELECT urls.id, urls.content FROM urls
        LIMIT ?"""
    for row in db.rows(query, limit):
        echoBookmarkRow(row)

proc echoBookmarksForDomain(domain: string) =
    let query = sql"""
        SELECT urls.id, urls.content FROM urls 
        WHERE urls.domain = ?"""
    for row in db.rows(query, domain):
        echoBookmarkRow(row)

proc echoBookmarksForTag(tag: string) =
    let query = sql"""
        SELECT urls.id, urls.content FROM urls JOIN tags ON urls.id = tags.url_id
        WHERE tags.value = ?"""
    for row in db.rows(query, tag):
        echoBookmarkRow(row)

initDB()

addBookmark("http://google.com", @["search", "technology"])
addBookmark("http://yahoo.com", @["search", "old"])

echo "Echo bookmarks"
echoBookmarks()

echo "Echo bookmarks for domain"
echoBookmarksForDomain("fakedomain.com")

echo "Echo bookmarks for tag"
echoBookmarksForTag("search")

db.close()

