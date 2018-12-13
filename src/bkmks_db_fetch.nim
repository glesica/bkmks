import
    db_sqlite,
    strutils

import
  bkmks_models

const DefaultLimit = 100
const DefaultStartId = 0

func fetchBkmks(db: DbConn,
                query: SqlQuery,
                params: varargs[string, `$`]): seq[Bkmk] =
    var bkmks = newSeq[Bkmk](0)
    for row in db.rows(query, params):
        let id = parseInt(row[0])
        bkmks.add(Bkmk(id: id, url: row[1]))
    return bkmks

func fetchBkmks*(db: DbConn,
                 limit: int = DefaultLimit,
                 startId: int = DefaultStartId): seq[Bkmk] =
    ## Fetches up to `limit` bookmarks. Results will be sorted by ID
    ## and `startId` it is the lowest-numbered ID returned that may
    ## be returned. Note that the lowest ID may be greater. This
    ## allows results to be paginated.
    let query = sql"""
        SELECT id, content, domain
        FROM urls
        WHERE id >= ?
        ORDER BY id asc
        LIMIT ?"""
    return fetchBkmks(db, query, startId, limit)

func fetchBkmks*(db: DbConn,
                 domain: string,
                 limit: int = DefaultLimit,
                 startId: int = DefaultStartId): seq[Bkmk] =
    ## Fetches bookmarks that refer to the given domain.
    let query = sql"""
        SELECT id, content
        FROM urls
        WHERE
            id >= ? and
            domain = ?
        ORDER BY id asc
        LIMIT ?"""
    return fetchBkmks(db, query, startId, domain, limit)

func fetchBkmks*(db: DbConn,
                 tags: seq[string],
                 limit: int = DefaultLimit,
                 startId: int = DefaultStartId): seq[Bkmk] =
    ## Fetches bookmarks that contain all of the provided tags.
    let tagsStr = join(tags, ",")
    let query = sql"""
        SELECT urls.id, urls.content
        FROM urls JOIN tags ON
            urls.id = tags.url_id and
            instr(?, tags.value) > 0
        WHERE id >= ? and
        ORDER BY id asc
        LIMIT ?"""
    return fetchBkmks(db, query, tagsStr, startId, limit)

func fetchTags*(db: DbConn, b: Bkmk): seq[string] =
    ## Fetch all tags associated with a given bookmark.
    let query = sql"""
        SELECT value
        FROM tags
        WHERE url_id = ?"""
    var tags = newSeq[string](0)
    for row in db.rows(query, b.id):
        tags.add(row[0])
    return tags
