//
//  SixtyMinuteGauge.swift
//  Mobius
//
//  Custom circular gauge with optional animated gradient in overtime.
//

import SwiftUI

/// Fully custom, resizable circular gauge with optional animated gradient when counting up.
struct SixtyMinuteGauge: View {
    var progress: Double       // 0.0 → 1.0
    var label: String          // text in center
    var isPreAlert: Bool       // last 10 minutes or overtime
    var isCountingUp: Bool     // animate gradient when true
    var size: CGFloat = 300
    var lineWidth: CGFloat = 30
    var animationDuration: Double = 6 // seconds per full rotation

    @State private var spin: Double = 0        // drives gradient rotation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    ringGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90)) // start from top

            // Center label (color follows alert status)
            Text(label)
                .font(.system(size: size * 0.15, weight: .regular, design: .rounded))
                .foregroundColor(isPreAlert ? .red : .green)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Text("Timer"))
        .accessibilityValue(Text(label))
        .onAppear { handleSpin() }
        .onChange(of: isCountingUp) { handleSpin() }
        .onChange(of: reduceMotion) { handleSpin() }
    }

    private var clampedProgress: CGFloat {
        CGFloat(min(max(progress, 0), 1))
    }

    // MARK: - Gradient

    private var ringGradient: AngularGradient {
        if isCountingUp && !reduceMotion {
            // Animated gradient: rotates continuously while counting up
            let stops: [Gradient.Stop] = [
                .init(color: .red,    location: 0.0),
                .init(color: .orange, location: 0.3),
                .init(color: .white,  location: 0.5),
                .init(color: .orange, location: 0.7),
                .init(color: .red,    location: 0.9),
            ]
            return AngularGradient(
                gradient: Gradient(stops: stops),
                center: .center,
                startAngle: .degrees(spin),
                endAngle: .degrees(360 + spin)
            )
        } else if isPreAlert {
            // Static: green until ~83%, then red for last ~17%
            let stops: [Gradient.Stop] = [
                .init(color: .green, location: 0.0),
                .init(color: .green, location: 0.83),
                .init(color: .red,   location: 1.0)
            ]
            return AngularGradient(
                gradient: Gradient(stops: stops),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        } else {
            // Normal: solid green
            let stops: [Gradient.Stop] = [
                .init(color: .green, location: 0.0),
                .init(color: .green, location: 1.0)
            ]
            return AngularGradient(
                gradient: Gradient(stops: stops),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        }
    }

    private func handleSpin() {
        guard isCountingUp, !reduceMotion else {
            withAnimation(.easeOut(duration: 0.2)) { spin = 0 }
            return
        }
        spin = 0
        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
            spin = 360
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        // Normal
        SixtyMinuteGauge(progress: 0.25, label: "45:00", isPreAlert: false, isCountingUp: false, size: 160, lineWidth: 14)
        // Pre‑alert (static split green→red)
        SixtyMinuteGauge(progress: 0.85, label: "09:00", isPreAlert: true,  isCountingUp: false, size: 160, lineWidth: 14)
        // Overtime (animated gradient)
        SixtyMinuteGauge(progress: 1.0,  label: "00:30", isPreAlert: true,  isCountingUp: true,  size: 160, lineWidth: 14, animationDuration: 6)
    }
}
