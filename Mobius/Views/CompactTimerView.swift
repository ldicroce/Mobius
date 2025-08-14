//
//  CompactTimerView.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//

import SwiftUI

struct CompactTimerView: View {
    @ObservedObject var vm: StandTimerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Gauge + controls (no logs)
            HStack(spacing: 28) {
                SixtyMinuteGauge(
                    progress: gaugeProgress,
                    label: centerLabel,
                    isPreAlert: vm.isInPreAlert,
                    isCountingUp: vm.isCountingUp,
                    size: 120,
                    lineWidth: 10
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
            .padding(24)
//#if os(macOS)
//            .background(WindowResizer(width: 520, height: 160, animate: true, center: false))
//            .background(WindowMinSizeEnforcer(minWidth: 520, minHeight: 160))
//#endif
        }
    }
    
    // MARK: - Helpers (duplicate of the small calculations)
    
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
}
