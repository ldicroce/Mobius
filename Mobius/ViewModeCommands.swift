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

    @Environment(\.openWindow) private var openWindow   // ← add this

    var body: some Commands {
        CommandMenu("View") {
            Picker("Layout", selection: $appVM.viewMode) {
                Text("Timer & Logs").tag(AppViewModel.ViewMode.timerAndLogs)
                Text("Compact Timer").tag(AppViewModel.ViewMode.compactTimer)
            }
            .onChange(of: appVM.viewMode) { _, _ in appVM.bringToFrontOrOpen() }

            Divider()

            Button("Timer & Logs") {
                appVM.viewMode = .timerAndLogs
                bringToFrontOrOpen()
            }.keyboardShortcut("1", modifiers: .command)

            Button("Compact Timer") {
                appVM.viewMode = .compactTimer
                bringToFrontOrOpen()
            }.keyboardShortcut("2", modifiers: .command)
        }
    }

    private func bringToFrontOrOpen() {
        if let _ = appVM.mainWindow {
            appVM.bringToFrontOrOpen()            // shows hidden window
        } else {
            openWindow(id: "main")                 // creates a new window if none exists
        }
    }
}
#endif

