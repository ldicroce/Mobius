//
//  SixtyMinuteGauge.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//

import SwiftUI

/// Fully custom, resizable circular gauge.
struct SixtyMinuteGauge: View {
    var progress: Double       // 0.0 → 1.0
    var label: String          // text in center (e.g., "33m", "08:35")
    var isPreAlert: Bool       // changes colors in last 10 minutes
    var size: CGFloat = 300    // diameter of the gauge
    var lineWidth: CGFloat = 30 // thickness of the ring
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        stops: isPreAlert
                        ? [
                            .init(color: .green, location: 0.0),   // green start
                            .init(color: .green, location: 0.83),  // stay green until ~83%
                            .init(color: .red,   location: 1.0)    // red for last ~17%
                        ]
                        : [
                            .init(color: .green, location: 0.0),
                            .init(color: .green, location: 1.0)   // fully green
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt) // flat ends
                )
                .rotationEffect(.degrees(-90)) // start from top
            
            // Center label (color matches alert status)
            Text(label)
                .font(.system(size: size * 0.15, weight: .regular, design: .rounded))
                .foregroundColor(isPreAlert ? .red : .green)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Text("Timer"))
        .accessibilityValue(Text(label))
    }
}
struct GaugePreview: View {
    let remainingMinutes: Double
    var body: some View {
        let progress = 1 - remainingMinutes / 60
        let label = String(format: "%02.0f:00", remainingMinutes)
        let preAlert = remainingMinutes <= 10
        return SixtyMinuteGauge(progress: progress, label: label, isPreAlert: preAlert)
    }
}
#Preview {
    VStack(spacing: 40) {
        GaugePreview(remainingMinutes: 45) // normal
        GaugePreview(remainingMinutes: 9)  // pre-alert
    }
}



//import SwiftUI
//
///// Fully custom, resizable circular gauge.
//struct SixtyMinuteGauge: View {
//    var progress: Double       // 0.0 → 1.0
//    var label: String          // text in center (e.g., "33m", "08:35")
//    var isPreAlert: Bool       // changes colors in last 10 minutes
//    var size: CGFloat = 300    // diameter of the gauge
//    var lineWidth: CGFloat = 30 // thickness of the ring
//
//    var body: some View {
//        ZStack {
//            // Background track
//            Circle()
//                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
//
//            // Progress ring
//            Circle()
//                .trim(from: 0, to: progress)
//                .stroke(
//                    AngularGradient(
//                        colors: isPreAlert
//                        ? [.green,.green,.green, .red]
//                        : [.green],
//                        // ? [.orange, .red]
//                        //: [.green, .yellow, .orange, .red],
//                        center: .center
//                    ),
//                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
//                )
//                .rotationEffect(.degrees(-90)) // start from top
//
//            // Center label
//            Text(label)
//                .font(.system(size: size * 0.15, weight: .regular, design: .rounded))
//        }
//        .frame(width: size, height: size)
//        .accessibilityLabel(Text("Timer"))
//        .accessibilityValue(Text(label))
//    }
//}
//
//#Preview {
//    VStack(spacing: 40) {
//        SixtyMinuteGauge(progress: 0.75, label: "15:00", isPreAlert: false)
//        SixtyMinuteGauge(progress: 0.15, label: "05:00", isPreAlert: true)
//    }
//}
