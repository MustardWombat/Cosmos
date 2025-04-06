import ActivityKit
import WidgetKit
import SwiftUI

struct StudyTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StudyTimerAttributes.self) { context in
            VStack {
                Text("📚 \(context.attributes.topic)")
                    .font(.headline)
                Text("⏳ \(formatTime(context.state.timeRemaining)) left")
                    .monospacedDigit()
            }
            .padding()
            .activityBackgroundTint(.black)
            .foregroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text("Studying: \(context.attributes.topic)")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("⏳ \(formatTime(context.state.timeRemaining)) left")
                }
            } compactLeading: {
                Text("📚")
            } compactTrailing: {
                Text("\(context.state.timeRemaining / 60)m")
            } minimal: {
                Text("⏳")
            }
        }
    }

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
