//
//  WindowRefSaver.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//



import SwiftUI
#if os(macOS)
import AppKit

struct WindowRefSaver: NSViewRepresentable {
    @ObservedObject var appVM: AppViewModel

    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        DispatchQueue.main.async { attach(to: v) }
        return v
    }

    func updateNSView(_ v: NSView, context: Context) {
        DispatchQueue.main.async { attach(to: v) }
    }

    private func attach(to v: NSView) {
        if let w = v.window {
            appVM.mainWindow = w
            w.isReleasedWhenClosed = false
        }
    }
}
#endif

