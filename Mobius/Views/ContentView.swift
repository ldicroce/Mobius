//
//  ContentView.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var vm = StandTimerViewModel()

    var body: some View {
        let spec = appVM.spec   // from AppViewModel (sizes for current mode)

        Group {
            switch appVM.viewMode {
            case .timerAndLogs:
                TimerAndLogsView(vm: vm)
            case .compactTimer:
                CompactTimerView(vm: vm)
            }
        }
        #if os(macOS)
        .background(WindowRefSaver(appVM: appVM)) // capture NSWindow; keep ref alive
        .background(
            WindowResizer(
                width: spec.initial.width,
                height: spec.initial.height,
                animate: false,
                center: false
            )
        )
        .background(
            WindowMinSizeEnforcer(
                minWidth: spec.min.width,
                minHeight: spec.min.height
            )
        )
        .onChange(of: appVM.viewMode) { _, _ in
            appVM.bringToFrontOrOpen()
        }
        #endif
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
