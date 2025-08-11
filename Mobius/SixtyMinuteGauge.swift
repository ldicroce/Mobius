//
//  SixtyMinuteGauge.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//

import SwiftUI
import Combine

struct SixtyMinuteGauge: View {
    private let total: TimeInterval = 10// 60 * 60
    @State private var endDate: Date?
    @State private var isRunning = false
    @State private var remaining: TimeInterval = 10//60  * 60

    // smooth updates
    private let ticker = Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()
    private var progress: Double { 1 - remaining / total }

    var body: some View {
        VStack(spacing: 24) {
            Gauge(value: progress, in: 0...1) {
                Text(timeString(remaining))
                    .font(.system(size: 36, weight: .regular, design: .rounded))
            }
            .gaugeStyle(.accessoryCircularCapacity) // ring style
            .tint(Gradient(colors: [.red, .mint]))// 2‑color ring
            .frame(width: 220, height: 220)
            .onReceive(ticker) { _ in tick() }
            .accessibilityLabel(Text("Timer")) // VoiceOver will read “Timer”
            .accessibilityValue(Text(timeString(remaining)))

            HStack(spacing: 16) {
                Button("Cancel", role: .destructive) { reset() }
                    .buttonStyle(.bordered)

                Button(isRunning ? "Pause" : "Start") { toggle() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .onAppear { reset() }
    }

    private func toggle() {
        if isRunning {
            // pause
            remaining = max(0, endDate?.timeIntervalSinceNow ?? remaining)
            endDate = nil
            isRunning = false
        } else {
            // start/resume
            endDate = Date().addingTimeInterval(remaining)
            isRunning = true
        }
    }

    private func reset() {
        isRunning = false
        endDate = nil
        remaining = total
    }

    private func tick() {
        guard isRunning, let end = endDate else { return }
        remaining = max(0, end.timeIntervalSinceNow)
        if remaining == 0 { isRunning = false }
    }

    private func timeString(_ t: TimeInterval) -> String {
        let f = DateComponentsFormatter()
        f.allowedUnits = t >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = [.pad]
        return f.string(from: t) ?? "00:00"
    }
}
#Preview {
    SixtyMinuteGauge()
}
