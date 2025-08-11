//
//  ContentView.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = StandTimerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // One fixed-height row for title + snooze + switch
            HStack {
                Text(vm.isInPreAlert ? "Time to get up?" : "")
                    .font(.system(size: 32, weight: .regular, design: .default))

                Spacer()

                Button("Snooze") {
                    // Next iteration: show notifications & snooze logic
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Toggle(isOn: $vm.isEnabled) {
                    Text(vm.isEnabled ? "ON" : "OFF")
                        .font(.headline)
                }
                .toggleStyle(.switch)
                .frame(width: 140)
            }
            .frame(height: 50) // ✅ Always this tall, even without text


            // --- rest of your layout (gauge + controls + logs) ---

            // Gauge + controls
            HStack(spacing: 28) {
                SixtyMinuteGauge(
                    progress: gaugeProgress,
                    label: centerLabel,
                    isPreAlert: vm.isInPreAlert,
                    size: 120,      // outer diameter
                    lineWidth: 10   // ring thickness
                )

                VStack(alignment: .leading, spacing: 12) {
//                    Text(bigTimeString)
//                        .font(.system(size: 48, weight: .medium, design: .rounded))

                    HStack(spacing: 12) {
                        Button("I stood up") {
                            vm.stoodUpNow()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!vm.isEnabled)

                        Button("Cancel", role: .destructive) {
                            vm.cancel()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Spacer()
            }

            // Logs
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Time").fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Logged").fontWeight(.semibold)
                            .frame(width: 80, alignment: .leading)
                    }
                    .padding(.horizontal, 8)

                    Divider()

                    List(vm.logs, id: \.self) { date in
                        HStack {
                            Text(timeOnly(date))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Yes")
                                .frame(width: 80, alignment: .leading)
                        }
                    }
                    .frame(minHeight: 180)
                }
                .padding(8)
            }

            Spacer()
        }
        .padding(24)
    }

    // MARK: - Helpers

    private var gaugeProgress: Double {
        let p = 1 - vm.remaining / vm.total
        return min(max(p, 0), 1)
    }

    private var centerLabel: String {
        let t = vm.remaining
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var bigTimeString: String {
        vm.remaining >= 60
        ? "\(Int(vm.remaining / 60))m"
        : "\(Int(vm.remaining))s"
    }

    private func timeOnly(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}

#Preview {
    ContentView()
}
