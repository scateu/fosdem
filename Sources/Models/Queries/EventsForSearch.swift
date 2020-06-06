import GRDB

struct EventsForSearch: PersistenceServiceRead {
    let query: String

    func perform(in database: Database) throws -> [Event] {
        try Event.fetchAll(database, sql: """
        SELECT events.*
        FROM events JOIN events_search ON events.id = events_search.id
        WHERE events_search MATCH ?
        ORDER BY bm25(events_search, 5.0, 2.0, 5.0, 3.0, 1.0, 1.0, 3.0)
        """, arguments: [FTS5Pattern(matchingAnyTokenIn: query)])
    }
}
