//
//  AppViewModel.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//

//
//  AppViewModel.swift
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

// Window/layout sizing spec used by the router and helpers
struct LayoutSpec {
    let initial: CGSize   // set when the layout becomes active (WindowResizer)
    let min: CGSize       // clamp during user resizing (WindowMinSizeEnforcer)
}

final class AppViewModel: ObservableObject {
    // MARK: Layout selection
    enum ViewMode: String, CaseIterable, Identifiable {
        case timerAndLogs = "Timer & Logs"
        case compactTimer = "Compact Timer"
        var id: String { rawValue }
    }

    // Persist the selected layout (so it sticks across launches)
    @AppStorage("viewMode") private var viewModeRaw: String = ViewMode.timerAndLogs.rawValue
    var viewMode: ViewMode {
        get { ViewMode(rawValue: viewModeRaw) ?? .timerAndLogs }
        set {
            if viewModeRaw != newValue.rawValue {
                objectWillChange.send()     // notify bindings (e.g., Picker) about the change
                viewModeRaw = newValue.rawValue
            }
        }
    }

    // Central place for sizes per layout
    // (edit these two lines if you ever tweak sizes)
    var spec: LayoutSpec {
        switch viewMode {
        case .timerAndLogs:
            return .init(initial: .init(width: 520, height: 400),
                         min:     .init(width: 520, height: 400))
        case .compactTimer:
            return .init(initial: .init(width: 520, height: 160),
                         min:     .init(width: 520, height: 160))
        }
    }

    // MARK: macOS window integration
    #if os(macOS)
    /// Keep a reference to the main NSWindow (captured by WindowRefSaver)
    @MainActor weak var mainWindow: NSWindow?

    /// Bring the main window to front and activate the app.
    @MainActor
    func showMainWindow() {
        if let w = mainWindow {
            w.makeKeyAndOrderFront(nil)
        } else {
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Unified helper you can call from menus etc. (we “hide on close”, so showing is enough)
    @MainActor
    func bringToFrontOrOpen() {
        showMainWindow()
    }
    #endif
}
