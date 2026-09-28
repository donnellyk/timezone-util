import Foundation
import Testing
import ZonesKit

@Suite struct DailyWindowTests {
    let newYorkMonday = DateInterval(
        start: date(2026, 9, 28, in: "America/New_York"),
        end: date(2026, 9, 29, in: "America/New_York"))

    @Test func weekdayOccurrenceUsesLocalWallClock() {
        let intervals = nineToFive.intervals(
            overlapping: newYorkMonday, in: zone("America/New_York"))
        #expect(
            intervals == [
                DateInterval(
                    start: date(2026, 9, 28, 9, in: "America/New_York"),
                    end: date(2026, 9, 28, 17, in: "America/New_York"))
            ])
    }

    @Test func weekendHasNoOccurrence() {
        let saturday = DateInterval(
            start: date(2026, 10, 3, in: "America/New_York"), duration: 86_400)
        #expect(nineToFive.intervals(overlapping: saturday, in: zone("America/New_York")).isEmpty)
    }

    @Test func overnightWindowEndsTheNextDay() {
        let night = DailyWindow(
            start: TimeOfDay(hour: 22), end: TimeOfDay(hour: 6), weekdays: DailyWindow.everyDay)
        let intervals = night.intervals(overlapping: newYorkMonday, in: zone("America/New_York"))
        #expect(
            intervals == [
                DateInterval(
                    start: date(2026, 9, 27, 22, in: "America/New_York"),
                    end: date(2026, 9, 28, 6, in: "America/New_York")),
                DateInterval(
                    start: date(2026, 9, 28, 22, in: "America/New_York"),
                    end: date(2026, 9, 29, 6, in: "America/New_York")),
            ])
    }

    @Test func daylightSavingChangeKeepsWallClockHours() {
        let everyDay = DailyWindow(
            start: TimeOfDay(hour: 9), end: TimeOfDay(hour: 17), weekdays: DailyWindow.everyDay)
        let fallBack = DateInterval(
            start: date(2026, 11, 1, in: "America/New_York"),
            end: date(2026, 11, 2, in: "America/New_York"))
        let intervals = everyDay.intervals(overlapping: fallBack, in: zone("America/New_York"))
        #expect(intervals.map(\.start) == [date(2026, 11, 1, 14, in: "UTC")])
        #expect(intervals.map(\.duration) == [8 * 3600])
    }
}
