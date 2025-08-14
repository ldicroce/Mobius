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
            
            // Remove File ▸ New Window / ⌘N
            CommandGroup(replacing: .newItem) { }
            
            // Keep File menu visible with at least one item
#if os(macOS)
            CommandGroup(after: .newItem) {
                Button("Close Window") {
                    NSApp.keyWindow?.performClose(nil) // routes to windowShouldClose → hide
                }
                .keyboardShortcut("w", modifiers: .command)
            }
#endif
        }
    }
}

