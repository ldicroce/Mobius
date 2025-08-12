//
//  ContentView.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = StandTimerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Top bar: title + snooze + switch (fixed height so layout won't shift)
            HStack {
                Text(vm.isInPreAlert ? "Time to get up!" : "")
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
            .frame(height: 50)

            // Auto-restart picker row (fixed height; always present to avoid shifting)
            HStack {
                Spacer()
                Picker("Auto-Restart", selection: $vm.autoRestartSetting) {
                    ForEach(StandTimerViewModel.AutoRestartSetting.allCases, id: \.self) { setting in
                        Text(setting.label).tag(setting)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)
            }
            .frame(height: 36)

            // Gauge + controls
            HStack(spacing: 28) {
                SixtyMinuteGauge(
                    progress: gaugeProgress,
                    label: centerLabel,
                    isPreAlert: vm.isInPreAlert,
                    isCountingUp: vm.isCountingUp,
                    size: 120,
                    lineWidth: 10
                )

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Button("I stood up") { vm.stoodUpNow() }
                            .buttonStyle(.borderedProminent)
                            .disabled(!vm.isEnabled)

                        Button("Cancel", role: .destructive) { vm.cancel() }
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

    // When counting up, keep the ring full.
    private var gaugeProgress: Double {
        if vm.isCountingUp { return 1.0 }
        let p = 1 - vm.remaining / vm.total
        return min(max(p, 0), 1)
    }

    // Center label: shows mm:ss remaining, then mm:ss elapsed after zero.
    private var centerLabel: String {
        let t = vm.isCountingUp ? vm.elapsedAfterZero : vm.remaining
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
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
