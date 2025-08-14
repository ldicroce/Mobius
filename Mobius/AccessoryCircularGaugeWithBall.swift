//
//  AccessoryCircularGaugeWithBall.swift
//  GaugeDemo
//
//  Created by Luciano Di Croce on 12/8/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Accessory-circular ring where a little ball rides the end of the progress arc.
/// - Gap is centered at the bottom.
/// - Ball follows the arc (no straight-line jump).
/// - Start / (optional) mid / end colors are configurable.
struct AccessoryCircularGaugeWithBall: View {
    var progress: CGFloat          // 0...1
    var size: CGFloat = 160
    var lineWidth: CGFloat = 12
    var sweep: Angle = .degrees(300)      // visible arc length
    var trackColor: Color = .gray.opacity(0.18)

    // MARK: <<< configurable colors >>> //  Thease are later overruled by the code located in: 'Styling rules mapped to Mobius states' of SixtyMinuteGauge
    var startColor: Color = .green
    var midColor: Color? = .yellow       // set nil to have only start→end
    var endColor: Color = .red

    /// If nil, the dot color is sampled from the ring gradient at `progress`.
    var dotColor: Color? = nil

    var rotate180: Bool = true           // optional flip

    private var clamped: CGFloat { min(max(progress, 0), 1) }
    private var sweepFraction: CGFloat { CGFloat(max(0, min(1, sweep.degrees / 360.0))) }

    /// Start angle so the gap is centered at the bottom (6 o'clock).
    private var startAngleBottomGap: Angle {
        let gap = 360 - sweep.degrees
        return .degrees(-90 + gap / 2)
    }

    /// The gradient across the *visible* sweep (0…1).
    private var ringGradient: Gradient {
        if let mid = midColor {
            return Gradient(stops: [
                .init(color: startColor, location: 0.0),
                .init(color: mid,        location: 0.5),
                .init(color: endColor,   location: 1.0)
            ])
        } else {
            return Gradient(stops: [
                .init(color: startColor, location: 0.0),
                .init(color: endColor,   location: 1.0)
            ])
        }
    }

    /// Build gradient stops over a *full 360°* so:
    /// 0 → startColor, (sweep/2) → (mid or lerp), sweep → endColor,
    /// and the stop at 1.0 wraps back to startColor so the *start* cap is correct.
    private var fullCircleStops: [Gradient.Stop] {
        let midAt: Color = midColor ?? colorBetween(startColor, endColor, 0.5)
        let midLoc = sweepFraction * 0.5
        let endLoc = sweepFraction

        return [
            .init(color: startColor, location: 0.0),
            .init(color: midAt,      location: midLoc),
            .init(color: endColor,   location: endLoc),
            .init(color: startColor, location: 1.0) // wrap back so start cap is startColor
        ]
    }

    /// Sample the visible-sweep gradient at 0…1 for the dot color.
    private func colorOnSweep(_ t: CGFloat) -> Color {
        color(in: ringGradient, at: min(max(t, 0), 1))
    }

    var body: some View {
        let start = startAngleBottomGap

        ZStack {
            // TRACK
            Circle()
                .trim(from: 0, to: sweepFraction)
                .stroke(trackColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(start)

            // PROGRESS ARC (round caps, no green tail)
            Circle()
                .trim(from: 0, to: sweepFraction * clamped)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: fullCircleStops),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(359.999)     // avoid wrap precision issues
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(start)
        }
        // Ball that truly follows the arc (animates via angle/progress)
        .modifier(DotOnArc(
            progress: clamped,
            lineWidth: lineWidth,
            startAngle: start,
            sweep: sweep,
            color: dotColor ?? colorOnSweep(clamped)
        ))
        .frame(width: size, height: size)
        .rotationEffect(rotate180 ? .degrees(180) : .degrees(0))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(clamped * 100)) percent")
    }
}

// MARK: - Dot animator

/// Animates the ball by interpolating `progress` (the angle), so it follows the arc.
private struct DotOnArc: AnimatableModifier {
    var progress: CGFloat          // 0...1
    var lineWidth: CGFloat
    var startAngle: Angle
    var sweep: Angle
    var color: Color

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geo in
                let side = min(geo.size.width, geo.size.height)
                let r = side / 2                               // path radius (center of stroke)
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let theta = startAngle.radians + sweep.radians * Double(min(max(progress, 0), 1))
                let x = center.x + CGFloat(cos(theta)) * r
                let y = center.y + CGFloat(sin(theta)) * r
                let dotDiameter = lineWidth * 1.1

                Circle()
                    .fill(color)
                    .frame(width: dotDiameter, height: dotDiameter)
                    .position(x: x, y: y)
                    .shadow(radius: 0.8, y: 0.6)
                    .allowsHitTesting(false)
            }
        )
    }
}

// MARK: - Color sampling / interpolation helpers

/// Returns the color from `gradient` at location `t ∈ [0,1]`.
private func color(in gradient: Gradient, at t: CGFloat) -> Color {
    let stops = gradient.stops.sorted { $0.location < $1.location }
    guard let first = stops.first else { return .clear }
    guard let last  = stops.last  else { return .clear }

    if t <= first.location { return first.color }
    if t >= last.location  { return last.color  }

    // Find segment [a, b] that contains t
    var a = first
    for b in stops.dropFirst() {
        if t <= b.location {
            let u = (t - a.location) / max(b.location - a.location, 0.000001)
            return lerp(a.color, b.color, u)
        }
        a = b
    }
    return last.color
}

/// Linear interpolate two colors in RGB.
private func lerp(_ c0: Color, _ c1: Color, _ t: CGFloat) -> Color {
    let a = rgba(c0), b = rgba(c1)
    return Color(
        red:   Double(a.r + (b.r - a.r) * t),
        green: Double(a.g + (b.g - a.g) * t),
        blue:  Double(a.b + (b.b - a.b) * t),
        opacity: Double(a.a + (b.a - a.a) * t)
    )
}

/// Mid color between two colors (t ∈ [0,1]).
private func colorBetween(_ c0: Color, _ c1: Color, _ t: CGFloat) -> Color {
    lerp(c0, c1, t)
}

/// Extract RGBA components in device RGB.
private func rgba(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    #if os(macOS)
    let ns = NSColor(color)
    // Prefer deviceRGB, then sRGB, otherwise use as-is
    let c: NSColor = (ns.usingColorSpace(.deviceRGB) ?? ns.usingColorSpace(.sRGB)) ?? ns
    return (c.redComponent, c.greenComponent, c.blueComponent, c.alphaComponent)
    #else
    let ui = UIColor(color)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
        return (r, g, b, a)
    }
    // Fallback: attempt CoreGraphics conversion to device RGB
    if let cg = ui.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(),
                                     intent: .defaultIntent,
                                     options: nil),
       let comps = cg.components, comps.count >= 4 {
        return (comps[0], comps[1], comps[2], comps[3])
    }
    return (0, 0, 0, 1)
    #endif
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
