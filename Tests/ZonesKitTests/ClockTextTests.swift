import Foundation
import Testing
import ZonesKit

@Suite struct ClockTextTests {
    @Test(arguments: [
        (TimeOfDay(hour: 0, minute: 5), false, "12:05 AM"),
        (TimeOfDay(hour: 12), false, "12:00 PM"),
        (TimeOfDay(hour: 13, minute: 30), false, "1:30 PM"),
        (TimeOfDay(hour: 13, minute: 30), true, "13:30"),
        (TimeOfDay(hour: 7), true, "07:00"),
    ])
    func timeOfDay(time: TimeOfDay, use24Hour: Bool, expected: String) {
        #expect(ClockText.time(time, use24Hour: use24Hour) == expected)
    }

    @Test func timeInAZone() {
        let moment = date(2026, 9, 28, 18, 41, in: "UTC")
        #expect(ClockText.time(moment, in: zone("America/New_York"), use24Hour: false) == "2:41 PM")
    }

    @Test(arguments: [
        (TimeInterval(3 * 3600 + 12 * 60), "3h 12m"),
        (TimeInterval(45 * 60), "45m"),
        (TimeInterval(2 * 3600), "2h"),
        (TimeInterval(30), "1m"),
    ])
    func duration(interval: TimeInterval, expected: String) {
        #expect(ClockText.duration(interval) == expected)
    }

    @Test func offsets() {
        let moment = date(2026, 9, 28, 12, in: "UTC")
        #expect(
            ClockText.offset(
                of: zone("America/New_York"), from: zone("America/Los_Angeles"), at: moment)
                == "+3h")
        #expect(
            ClockText.offset(
                of: zone("America/Los_Angeles"), from: zone("America/New_York"), at: moment)
                == "−3h")
        #expect(
            ClockText.offset(of: zone("Asia/Kolkata"), from: zone("UTC"), at: moment) == "+5h 30m")
        #expect(ClockText.offset(of: zone("UTC"), from: zone("UTC"), at: moment) == "Same time")
    }

    @Test func dayRelation() {
        let laEvening = date(2026, 9, 28, 20, in: "America/Los_Angeles")
        #expect(
            ClockText.dayRelation(
                of: laEvening, in: zone("Asia/Tokyo"), relativeTo: zone("America/Los_Angeles"))
                == "Tomorrow")
        #expect(
            ClockText.dayRelation(
                of: laEvening, in: zone("America/New_York"), relativeTo: zone("America/Los_Angeles")
            )
                == nil)
    }

    @Test func hourLabels() {
        #expect(
            [0, 6, 12, 18, 24].map { ClockText.hourLabel($0, use24Hour: false) } == [
                "12a", "6a", "12p", "6p", "12a",
            ])
        #expect(
            [0, 6, 12, 18, 24].map { ClockText.hourLabel($0, use24Hour: true) } == [
                "00", "06", "12", "18", "24",
            ])
    }

    @Test func statusText() {
        #expect(ClockText.status(.working) == nil)
        #expect(ClockText.status(.startsLater(in: 65 * 60)) == "Starts in 1h 5m")
        #expect(ClockText.status(.finished) == "Done for the day")
        #expect(ClockText.status(.dayOff) == "Day off")
    }
}
