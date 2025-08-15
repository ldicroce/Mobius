//
//  TimerAndLogsView.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//

import SwiftUI

struct TimerAndLogsView: View {
    @ObservedObject var vm: StandTimerViewModel
    @State private var showClearAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Gauge + controls (your current layout)
            HStack(spacing: 28) {
                SixtyMinuteGauge(
                  progress: vm.gaugeProgress,
                  label: vm.centerLabel,
                  isPreAlert: vm.isInPreAlert,
                  isCountingUp: vm.isCountingUp,
                  size: 120, lineWidth: 10
                )

                VStack(alignment: .center, spacing: 32) {
                    Text(vm.isInPreAlert ? "Time to get up!" : "")
                        .font(.system(size: 22, weight: .regular, design: .default))
                        .frame(height: 30)

                    HStack(spacing: 12) {
                        VStack(spacing: 12) {
                            Button("I stood up") { vm.stoodUpNow() }
                                .buttonStyle(.borderedProminent)
                                .disabled(!vm.isEnabled)

                            Button("Cancel", role: .destructive) { vm.cancel() }
                                .buttonStyle(.bordered)
                        }
                        Spacer()

                        Button("Snooze") {
                            // TODO: notifications & snooze logic
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                        Toggle(isOn: $vm.isEnabled) {
                            Text(vm.isEnabled ? "ON" : "OFF")
                                .font(.headline)
                        }
                        .toggleStyle(.switch)
                        .frame(width: 100)
                    }
                }
                Spacer()
            }

            // Logs
            GroupBox {
                VStack(alignment: .leading) {
                    HStack(spacing: 12) {
                        Text("Time").fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Logged").fontWeight(.semibold)
                            .frame(width: 80, alignment: .leading)

                        Spacer()
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

            // Bottom bar
            HStack(spacing: 8) {
                Picker("Auto-Restart", selection: $vm.autoRestartSetting) {
                    ForEach(StandTimerViewModel.AutoRestartSetting.allCases, id: \.self) { setting in
                        Text(setting.label).tag(setting)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)

                Spacer()

                Button {
                    showClearAlert = true
                } label: {
                    HStack(spacing: 6) {
                        Text("Clear Log")
                        if vm.logs.count > 0 {
                            Text("\(vm.logs.count)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .buttonStyle(.bordered)
                .disabled(vm.logs.isEmpty)
            }
            .alert("Clear all log entries?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { vm.clearLogs() }
            } message: {
                Text("This action cannot be undone.")
            }
        }
        .padding(24)
//#if os(macOS)
//            .background(WindowResizer(width: 520, height: 400, animate: true, center: false))
//            .background(WindowMinSizeEnforcer(minWidth: 520, minHeight: 400))
//#endif
    }

    // MARK: - Helpers (same logic you had in ContentView)

    private var gaugeProgress: Double {
        if vm.isCountingUp { return 1.0 }
        let p = 1 - vm.remaining / vm.total
        return min(max(p, 0), 1)
    }

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

