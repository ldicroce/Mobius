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
        WindowGroup(id: "main") {          // ← add id
            ContentView()
                .environmentObject(appVM)
        }
        .commands {
            ViewModeCommands(appVM: appVM)
            CommandGroup(replacing: .newItem) { }
#if os(macOS)
            CommandGroup(after: .newItem) {
                Button("Close Window") { NSApp.keyWindow?.performClose(nil) } // hides via delegate
                    .keyboardShortcut("w", modifiers: .command)
            }
#endif
        }
    }
}
