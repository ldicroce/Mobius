//
//  MobiusApp.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

@main
struct MobiusApp: App {
    @StateObject private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appVM)
        }
        .commands {
            // keep your custom "View" menu
            ViewModeCommands(appVM: appVM)

            // 1) Remove "New …" (including New Window / ⌘N)
            CommandGroup(replacing: .newItem) { }

            // 2) Add at least one File item so the File menu stays visible
            CommandGroup(after: .newItem) {
                #if os(macOS)
                Button("Close Window") {
                    NSApp.keyWindow?.performClose(nil)
                }
                .keyboardShortcut("w", modifiers: .command)
                #endif
            }
        }
    }
}
