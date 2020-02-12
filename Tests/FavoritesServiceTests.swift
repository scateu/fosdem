@testable
import Fosdem
import XCTest

final class FavoritesServiceTests: XCTestCase {
    func testAddTrack() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addTrack("1")
        service.addTrack("2")
        service.addTrack("3")
        XCTAssertEqual(service.tracks, ["1", "2", "3"])

        service.addTrack("3")
        XCTAssertEqual(service.tracks, ["1", "2", "3"])
    }

    func testRemoveTrack() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addTrack("1")
        service.addTrack("2")
        service.addTrack("3")

        service.removeTrack("3")
        XCTAssertEqual(service.tracks, ["1", "2"])

        service.removeTrack("2")
        XCTAssertEqual(service.tracks, ["1"])

        service.removeTrack("1")
        XCTAssertEqual(service.tracks, [])
    }

    func testMissingTrackRemove() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addTrack("2")
        service.removeTrack("2")
        XCTAssertEqual(service.tracks, [])
    }

    func testDuplicateTrackRemove() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addTrack("1")
        service.removeTrack("1")
        service.removeTrack("1")
        XCTAssertEqual(service.tracks, [])
    }

    func testPreservesTrackSorting() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addTrack("c")
        service.addTrack("a")
        XCTAssertEqual(service.tracks, ["a", "c"])

        service.addTrack("b")
        XCTAssertEqual(service.tracks, ["a", "b", "c"])

        service.removeTrack("a")
        XCTAssertEqual(service.tracks, ["b", "c"])

        service.removeTrack("c")
        XCTAssertEqual(service.tracks, ["b"])
    }

    func testAddEvent() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addEvent(withIdentifier: "1")
        XCTAssert(service.containsEvent(withIdentifier: "1"))

        service.addEvent(withIdentifier: "2")
        XCTAssert(service.containsEvent(withIdentifier: "1"))
        XCTAssert(service.containsEvent(withIdentifier: "2"))

        service.addEvent(withIdentifier: "3")
        XCTAssert(service.containsEvent(withIdentifier: "1"))
        XCTAssert(service.containsEvent(withIdentifier: "2"))
        XCTAssert(service.containsEvent(withIdentifier: "3"))
    }

    func testDuplicateEventAdd() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addEvent(withIdentifier: "1")
        service.addEvent(withIdentifier: "1")
        XCTAssert(service.containsEvent(withIdentifier: "1"))

        service.addEvent(withIdentifier: "2")
        service.addEvent(withIdentifier: "2")
        XCTAssert(service.containsEvent(withIdentifier: "1"))
        XCTAssert(service.containsEvent(withIdentifier: "2"))
    }

    func testRemoveEvent() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addEvent(withIdentifier: "1")
        service.addEvent(withIdentifier: "2")
        service.addEvent(withIdentifier: "3")

        service.removeEvent(withIdentifier: "2")
        XCTAssertTrue(service.containsEvent(withIdentifier: "1"))
        XCTAssertTrue(service.containsEvent(withIdentifier: "3"))
        XCTAssertFalse(service.containsEvent(withIdentifier: "2"))

        service.removeEvent(withIdentifier: "1")
        XCTAssertTrue(service.containsEvent(withIdentifier: "3"))
        XCTAssertFalse(service.containsEvent(withIdentifier: "1"))
        XCTAssertFalse(service.containsEvent(withIdentifier: "2"))

        service.removeEvent(withIdentifier: "3")
        XCTAssertFalse(service.containsEvent(withIdentifier: "3"))
        XCTAssertFalse(service.containsEvent(withIdentifier: "1"))
        XCTAssertFalse(service.containsEvent(withIdentifier: "2"))
    }

    func testMissingEventRemove() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addEvent(withIdentifier: "1")
        service.removeEvent(withIdentifier: "2")
        XCTAssertTrue(service.containsEvent(withIdentifier: "1"))
        XCTAssertFalse(service.containsEvent(withIdentifier: "2"))
    }

    func testDuplicateEventRemove() {
        let service = FavoritesService(defaultsService: DefaultsServiceMock())
        service.addEvent(withIdentifier: "1")
        service.removeEvent(withIdentifier: "1")
        service.removeEvent(withIdentifier: "1")
        XCTAssertFalse(service.containsEvent(withIdentifier: "1"))
    }
}
