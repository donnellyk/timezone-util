import Foundation
import Testing
import ZonesKit

@Suite struct TimelineAxisTests {
    let chicagoDay = TimelineAxis.day(
        containing: date(2026, 9, 28, 12, in: "America/Chicago"), in: zone("America/Chicago"))

    @Test func workdayMapsIntoTheViewersDay() {
        let intervals = nineToFive.intervals(
            overlapping: chicagoDay.span, in: zone("America/New_York"))
        #expect(chicagoDay.segments(for: intervals) == [(8.0 / 24)...(16.0 / 24)])
    }

    @Test func segmentsClipToTheAxis() {
        let intervals = nineToFive.intervals(overlapping: chicagoDay.span, in: zone("Asia/Tokyo"))
        #expect(chicagoDay.segments(for: intervals) == [0...(3.0 / 24), (19.0 / 24)...1])
    }

    @Test func elapsedSegmentsStopAtNow() {
        let intervals = nineToFive.intervals(
            overlapping: chicagoDay.span, in: zone("America/New_York"))
        let now = date(2026, 9, 28, 12, in: "America/Chicago")
        #expect(chicagoDay.segments(for: intervals, before: now) == [(8.0 / 24)...(12.0 / 24)])
    }

    @Test func fractionClampsOutsideTheAxis() {
        #expect(chicagoDay.fraction(of: chicagoDay.span.start.addingTimeInterval(-60)) == 0)
        #expect(chicagoDay.fraction(of: chicagoDay.span.end.addingTimeInterval(60)) == 1)
    }

    @Test func dateAtAFractionSnapsToTheStep() {
        #expect(
            chicagoDay.date(at: 14.1 / 24, roundedTo: 900)
                == date(2026, 9, 28, 14, 0, in: "America/Chicago"))
        #expect(
            chicagoDay.date(at: 14.2 / 24, roundedTo: 900)
                == date(2026, 9, 28, 14, 15, in: "America/Chicago"))
    }

    @Test func dateAtAFractionClampsToTheAxis() {
        #expect(chicagoDay.date(at: -0.5, roundedTo: 900) == chicagoDay.span.start)
        #expect(chicagoDay.date(at: 1.5, roundedTo: 900) == chicagoDay.span.end)
    }

    @Test func dateAtAFractionOnADSTDay() {
        let fallBack = TimelineAxis.day(
            containing: date(2026, 11, 1, 12, in: "America/Chicago"), in: zone("America/Chicago"))
        #expect(
            fallBack.date(at: 13.0 / 25, roundedTo: 900)
                == date(2026, 11, 1, 12, in: "America/Chicago"))
    }

    @Test func ticksInTheAxisZone() {
        let ticks = chicagoDay.ticks(everyHours: 6, in: zone("America/Chicago"))
        #expect(ticks.map(\.hour) == [0, 6, 12, 18])
        #expect(ticks.map(\.fraction) == [0, 0.25, 0.5, 0.75])
    }

    @Test func ticksInAnotherZoneSitAtItsLocalHours() {
        let ticks = chicagoDay.ticks(everyHours: 6, in: zone("America/New_York"))
        #expect(ticks.map(\.hour) == [6, 12, 18, 0])
        #expect(ticks.map(\.fraction) == [5, 11, 17, 23].map { Double($0) / 24 })
    }

    @Test func halfHourZonesTickBetweenViewerHours() {
        let ticks = chicagoDay.ticks(everyHours: 12, in: zone("Asia/Kolkata"))
        #expect(ticks.map(\.hour) == [12, 0])
        #expect(ticks.map(\.fraction) == [1.5, 13.5].map { $0 / 24 })
    }
}
