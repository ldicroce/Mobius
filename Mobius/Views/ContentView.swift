//
//  ContentView.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var vm = StandTimerViewModel()

    var body: some View {
        let spec = appVM.viewMode.spec

        Group {
            switch appVM.viewMode {
            case .timerAndLogs:  TimerAndLogsView(vm: vm)
            case .compactTimer:  CompactTimerView(vm: vm)
            }
        }
        #if os(macOS)
        .background(WindowRefSaver(appVM: appVM)) // keep NSWindow reference
        // Force the *initial* content size when the view attaches/updates
        .background(WindowResizer(width: spec.initial.width,
                                  height: spec.initial.height,
                                  animate: false, center: false))
        // Enforce the *minimum* while the user resizes
        .background(WindowMinSizeEnforcer(minWidth: spec.min.width,
                                          minHeight: spec.min.height))
        .onChange(of: appVM.viewMode) { _, _ in appVM.bringToFrontOrOpen() }
        #endif
    }
}





