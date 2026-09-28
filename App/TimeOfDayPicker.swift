import SwiftUI
import ZonesKit

/// A menu of times in 30-minute steps. A saved time off the grid stays selectable.
struct TimeOfDayPicker: View {
    @Binding var selection: TimeOfDay
    let use24Hour: Bool

    private var options: [TimeOfDay] {
        Set(TimeOfDay.steps(every: 30) + [selection]).sorted()
    }

    var body: some View {
        Picker("Time", selection: $selection) {
            ForEach(options, id: \.self) { time in
                Text(ClockText.time(time, use24Hour: use24Hour)).tag(time)
            }
        }
        .labelsHidden()
        .fixedSize()
    }
}
