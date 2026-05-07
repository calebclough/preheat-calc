import SwiftUI
import UserNotifications

struct ResultsView: View {
    let result: CookingResult
    let unit: TemperatureUnit

    @Environment(\.dismiss) private var dismiss
    @State private var timerEndDate: Date?
    @State private var remainingSeconds: Int = 0
    @State private var timer: Timer?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary card
                VStack(spacing: 12) {
                    Text("Put food in now!")
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 30) {
                        VStack {
                            Text(TemperatureConverter.timeString(minutes: result.totalMinutes))
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Total Time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        VStack {
                            Text(TemperatureConverter.timeString(minutes: result.conventionalMinutes))
                                .font(.title3)
                            Text("Conventional")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if result.timeSavedMinutes > 0.5 {
                        Text("\(Int(round(result.timeSavedMinutes))) minutes saved!")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Chart
                VStack(alignment: .leading) {
                    Text("Temperature & Cooking Progress")
                        .font(.headline)

                    CookingChartView(
                        result: result,
                        unit: unit,
                        cookTempF: result.cookTempF
                    )
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Timer
                VStack(spacing: 12) {
                    if let _ = timerEndDate {
                        Text(timerString)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(remainingSeconds <= 60 ? .red : .primary)

                        Button("Cancel Timer", role: .destructive) {
                            cancelTimer()
                        }
                    } else {
                        Button {
                            startTimer()
                        } label: {
                            Label("Start Countdown Timer", systemImage: "timer")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var timerString: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func startTimer() {
        let totalSeconds = Int(round(result.totalMinutes * 60))
        remainingSeconds = totalSeconds
        timerEndDate = Date().addingTimeInterval(Double(totalSeconds))

        scheduleNotification(in: totalSeconds)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer?.invalidate()
            }
        }
    }

    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
        timerEndDate = nil
        remainingSeconds = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func scheduleNotification(in seconds: Int) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "Food is Ready!"
            content.body = "Your food should be done cooking. Time to check the oven!"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: Double(seconds),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "preheatcalc-timer",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }
}
