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
        Group {
            switch appVM.viewMode {
            case .timerAndLogs:  TimerAndLogsView(vm: vm)
            case .compactTimer:  CompactTimerView(vm: vm)
            }
        }
        #if os(macOS)
        .background(WindowRefSaver(appVM: appVM))  // capture window reference
        .onChange(of: appVM.viewMode) { _ in       // optional convenience
            appVM.bringToFrontOrOpen()
        }
        #endif
    }
}





