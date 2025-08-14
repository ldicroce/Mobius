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
            Picker("Layout", selection: $appVM.viewMode) {
                Text("Timer & Logs").tag(AppViewModel.ViewMode.timerAndLogs)
                Text("Compact Timer").tag(AppViewModel.ViewMode.compactTimer)
            }

            Divider()

            Button("Timer & Logs") {
                appVM.viewMode = .timerAndLogs
                appVM.showMainWindow()       // ← bring it back if hidden
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("Compact Timer") {
                appVM.viewMode = .compactTimer
                appVM.showMainWindow()       // ← bring it back if hidden
            }
            .keyboardShortcut("2", modifiers: .command)
        }
    }
}
#endif

