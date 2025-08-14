//
//  ViewModeCommands.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//

import SwiftUI

#if os(macOS)
struct ViewModeCommands: Commands {
    @ObservedObject var appVM: AppViewModel
    init(appVM: AppViewModel) { self._appVM = ObservedObject(wrappedValue: appVM) }

    var body: some Commands {
        CommandMenu("View") {
            // Radio picker for layout
            Picker("Layout", selection: $appVM.viewMode) {
                Text("Timer & Logs").tag(AppViewModel.ViewMode.timerAndLogs)
                Text("Compact Timer").tag(AppViewModel.ViewMode.compactTimer)
            }
            .onChange(of: appVM.viewMode) { _ in
                appVM.bringToFrontOrOpen()        // ← bring it back if hidden
            }

            Divider()

            // Handy shortcuts that also bring the window back
            Button("Timer & Logs") {
                appVM.viewMode = .timerAndLogs
                appVM.bringToFrontOrOpen()
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("Compact Timer") {
                appVM.viewMode = .compactTimer
                appVM.bringToFrontOrOpen()
            }
            .keyboardShortcut("2", modifiers: .command)
        }
    }
}
#endif

