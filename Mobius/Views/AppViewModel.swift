//
//  AppViewModel.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

final class AppViewModel: ObservableObject {
    enum ViewMode: String, CaseIterable, Identifiable {
        case timerAndLogs = "Timer & Logs"
        case compactTimer = "Compact Timer"
        var id: String { rawValue }
    }
    
    @Published var viewMode: ViewMode = .timerAndLogs
    
#if os(macOS)
    weak var mainWindow: NSWindow?
    
    func showMainWindow() {
        if let w = mainWindow {
            w.makeKeyAndOrderFront(nil)
        } else {
            // Fallback if the ref isn’t set yet
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Unified helper you can call from anywhere in the UI/menus.
    /// (Because we intercept Close and only hide, this is enough.)
    func bringToFrontOrOpen() {
        showMainWindow()
    }
#endif
}

// These provided unified values for the window size
struct LayoutSpec {
    let initial: CGSize   // initial content size when switching to this mode
    let min: CGSize       // minimum allowed content size
}

extension AppViewModel.ViewMode {
    var spec: LayoutSpec {
        switch self {
        case .timerAndLogs:
            return .init(initial: .init(width: 520, height: 400),
                         min:     .init(width: 520, height: 400))
        case .compactTimer:
            return .init(initial: .init(width: 520, height: 160),
                         min:     .init(width: 520, height: 160))
        }
    }
}
