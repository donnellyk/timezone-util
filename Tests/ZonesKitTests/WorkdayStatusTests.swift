import Foundation
import Testing
import ZonesKit

@Suite struct WorkdayStatusTests {
    let newYork = zone("America/New_York")

    @Test func midwayThroughTheWorkday() {
        let status = nineToFive.status(
            at: date(2026, 9, 28, 13, in: "America/New_York"), in: newYork)
        #expect(status == .working)
    }

    @Test func beforeTheWorkdayStarts() {
        let status = nineToFive.status(
            at: date(2026, 9, 28, 7, in: "America/New_York"), in: newYork)
        #expect(status == .startsLater(in: 2 * 3600))
    }

    @Test func afterTheWorkdayEnds() {
        let status = nineToFive.status(
            at: date(2026, 9, 28, 18, in: "America/New_York"), in: newYork)
        #expect(status == .finished)
    }

    @Test func weekendIsADayOff() {
        let status = nineToFive.status(
            at: date(2026, 10, 3, 12, in: "America/New_York"), in: newYork)
        #expect(status == .dayOff)
    }

    @Test func overnightShiftCountsFromTheDayItStarted() {
        let night = DailyWindow(
            start: TimeOfDay(hour: 22), end: TimeOfDay(hour: 6),
            weekdays: DailyWindow.mondayToFriday)
        let status = night.status(at: date(2026, 9, 29, 2, in: "America/New_York"), in: newYork)
        #expect(status == .working)
    }
}
