//
//  WindowResizer.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//

import SwiftUI
#if os(macOS)
import AppKit

/// Sets the window's *content* size when this view is rendered.
/// Use as a background on any SwiftUI view that's inside the window.
struct WindowResizer: NSViewRepresentable {
    let width: CGFloat
    let height: CGFloat
    var animate: Bool = true
    var center: Bool = false

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { resizeWindow(for: view) }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async { resizeWindow(for: view) }
    }

    private func resizeWindow(for view: NSView) {
        guard let window = view.window else { return }
        let target = NSSize(width: width, height: height)

        if animate {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.18
                window.animator().setContentSize(target)
            }
        } else {
            window.setContentSize(target)
        }

        if center {
            window.center()
        }
    }
}
#endif
