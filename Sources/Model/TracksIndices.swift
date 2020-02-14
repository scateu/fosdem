struct TracksIndices {
    let tracks: [String]
    let tracksForDay: [[Track]]
    let eventsForTrack: [Track: [Event]]
    let eventForIdentifier: [String: Event]
}

extension TracksIndices {
    init(schedule: Schedule) {
        var tracksSetsForDay: [Int: Set<Track>] = [:]
        var eventsForTrack: [Track: [Event]] = [:]
        var eventForIdentifier: [String: Event] = [:]

        for day in schedule.days {
            for event in day.events {
                eventForIdentifier[event.id] = event
                eventsForTrack[event.track, default: []].append(event)
                tracksSetsForDay[day.index, default: []].insert(event.track)
            }
        }

        let tracksForDay = tracksSetsForDay
            .sorted { lhs, rhs in lhs.key < rhs.key }
            .map { _, value in value.sorted() }

        let tracks = Set(tracksSetsForDay.values
            .flatMap { tracks in tracks })
            .sorted()

        self.init(tracks: tracks, tracksForDay: tracksForDay, eventsForTrack: eventsForTrack, eventForIdentifier: eventForIdentifier)
    }
}
