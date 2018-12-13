import
    db_sqlite

proc initDb(db: DbConn) =
    db.exec(sql"PRAGMA foreign_keys = ON")

    db.exec(sql"BEGIN")
    db.exec(sql"""
        CREATE TABLE IF NOT EXISTS urls (
            id      INTEGER PRIMARY KEY,
            content TEXT UNIQUE NOT NULL,
            domain  TEXT NOT NULL)""")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS urls_domain_idx ON urls(domain)")
    db.exec(sql"COMMIT")

    db.exec(sql"BEGIN")
    db.exec(sql"""
        CREATE TABLE IF NOT EXISTS tags (
            value VARCHAR(64) NOT NULL,
            url_id INTEGER NOT NULL REFERENCES urls(id)
                ON UPDATE CASCADE
                ON DELETE CASCADE)""")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS tags_value_idx ON tags(value)")
    db.exec(
        sql"CREATE INDEX IF NOT EXISTS tags_url_id_idx ON tags(url_id)")
    db.exec(sql"""
        CREATE UNIQUE INDEX IF NOT EXISTS
            tags_join_idx ON tags(value, url_id)""")
    db.exec(sql"COMMIT")

proc openDb*(path: string): DbConn =
    let db = open(path, "", "", "")
    initDb(db)
    return db
