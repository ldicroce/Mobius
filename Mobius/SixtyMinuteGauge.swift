//
//  SixtyMinuteGauge.swift
//  Mobius
//
//  Custom circular gauge with optional animated gradient in overtime.
//

import SwiftUI

struct SixtyMinuteGauge: View {
    var progress: Double       // 0.0 → 1.0 (Mobius drives this)
    var label: String          // center text (mm:ss)
    var isPreAlert: Bool       // last 10 minutes OR overtime
    var isCountingUp: Bool     // after zero (Mobius already sets this)
    var size: CGFloat = 300
    var lineWidth: CGFloat = 30

    // Visual options to match “Gauge demo”
    var sweep: Angle = .degrees(300)   // arc length with bottom gap
    var rotate180: Bool = true         // keeps the same orientation as the demo

    private var clamped: CGFloat { CGFloat(min(max(progress, 0), 1)) }

    var body: some View {
        ZStack {
            // The ring + ball (from Gauge demo)
            AccessoryCircularGaugeWithBall(
                progress: clamped,
                size: size,
                lineWidth: lineWidth,
                sweep: sweep,
                trackColor: .gray.opacity(0.18),

                // Colors: cool → warm during normal countdown,
                // become warm/red in pre-alert and overtime.
                startColor: startColor,
                midColor: midColor,
                endColor: endColor,
                dotColor: nil,             // nil = auto sample ring color at progress
                rotate180: rotate180
            )

            // Center time text (kept from Mobius)
            Text(label)
                .font(.system(size: size * 0.18, weight: .regular, design: .rounded))
                .monospacedDigit()
                .foregroundColor(centerTextColor)
                .accessibilityHidden(false)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Text("Timer"))
        .accessibilityValue(Text(label))
    }

    // MARK: - Styling rules mapped to Mobius states

    private var isWarmState: Bool { isPreAlert || isCountingUp }

    private var startColor: Color {
        isWarmState ? .teal : .teal         // match Gauge demo vibe in normal mode
    }
    private var midColor: Color? {
        isWarmState ? nil : .orange           // cool→warm gradient while counting down
    }
    private var endColor: Color {
        isWarmState ? .red : .pink            // push to red when pre-alert / overtime
    }
//    private var centerTextColor: Color {
//        isWarmState ? .secondary : .primary
//    }
    private var centerTextColor: Color {
        isCountingUp ? .red : .primary
    }
}

#Preview {
    VStack(spacing: 28) {
        // Normal countdown look
        SixtyMinuteGauge(progress: 0.25, label: "45:00", isPreAlert: false, isCountingUp: false, size: 160, lineWidth: 14)

        // Pre-alert (last 10 minutes)
        SixtyMinuteGauge(progress: 0.85, label: "09:00", isPreAlert: true,  isCountingUp: false, size: 160, lineWidth: 14)

        // Overtime (count-up) — ring stays full, warm/red styling
        SixtyMinuteGauge(progress: 1.0,  label: "00:30", isPreAlert: true,  isCountingUp: true,  size: 160, lineWidth: 14)
    }
}
