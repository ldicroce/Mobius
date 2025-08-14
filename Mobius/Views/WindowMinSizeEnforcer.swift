//
//  WindowMinSizeEnforcer.swift
//  Mobius
//
//  Created by Luciano Di Croce on 14/8/25.
//

// WindowMinSizeEnforcer.swift (chained version)


// WindowMinSizeEnforcer.swift
import SwiftUI
#if os(macOS)
import AppKit
import ObjectiveC   // ← needed for objc_(get|set)AssociatedObject

struct WindowMinSizeEnforcer: NSViewRepresentable {
    let minWidth: CGFloat
    let minHeight: CGFloat

    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        DispatchQueue.main.async { attach(to: v) }
        return v
    }

    func updateNSView(_ v: NSView, context: Context) {
        DispatchQueue.main.async { attach(to: v) }
    }

    private func attach(to view: NSView) {
        guard let window = view.window else { return }

        let minContent = NSSize(width: minWidth, height: minHeight)
        // Set both content + frame mins
        window.contentMinSize = minContent
        let minFrame = window.frameRect(forContentRect: NSRect(origin: .zero, size: minContent)).size
        window.minSize = minFrame

        // If already smaller, bump once
        let cs = window.contentLayoutRect.size
        if cs.width < minContent.width || cs.height < minContent.height {
            window.setContentSize(NSSize(width: max(cs.width,  minContent.width),
                                         height: max(cs.height, minContent.height)))
        }

        // Chain to any existing delegate instead of replacing behavior
        _ = ChainedWindowDelegate.ensure(on: window, minContentSize: minContent)
    }
}

private final class ChainedWindowDelegate: NSObject, NSWindowDelegate {
    weak var prior: NSWindowDelegate?
    weak var window: NSWindow?
    var minContentSize: NSSize

    init(window: NSWindow, prior: NSWindowDelegate?, minContentSize: NSSize) {
        self.window = window
        self.prior = prior
        self.minContentSize = minContentSize
        super.init()
    }

    // ✅ FIX #1: call responds(to:) (not responds?)
    override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) { return true }
        return prior?.responds(to: aSelector) ?? false
    }

    // ✅ FIX #2: same here; forward only if prior responds
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if prior?.responds(to: aSelector) ?? false {
            return prior
        }
        return super.forwardingTarget(for: aSelector)
    }

    // Live clamp while resizing (combine with prior if it implements the method)
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        let sizeFromPrior = prior?.windowWillResize?(sender, to: frameSize) ?? frameSize
        let minFrame = sender.frameRect(forContentRect: NSRect(origin: .zero, size: minContentSize)).size
        return NSSize(width: max(sizeFromPrior.width,  minFrame.width),
                      height: max(sizeFromPrior.height, minFrame.height))
    }

    // Install once per window
    private static var keyToken: UInt8 = 0

    static func ensure(on window: NSWindow, minContentSize: NSSize) -> ChainedWindowDelegate {
        if let existing = objc_getAssociatedObject(window, &keyToken) as? ChainedWindowDelegate {
            existing.minContentSize = minContentSize
            return existing
        }
        let chained = ChainedWindowDelegate(window: window, prior: window.delegate, minContentSize: minContentSize)
        window.delegate = chained
        objc_setAssociatedObject(window, &keyToken, chained, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return chained
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Let prior delegate observe the event if it wants
        _ = prior?.windowShouldClose?(sender)

        // Hide instead of closing (so we can re-show later)
        sender.orderOut(nil)
        return false
    }
}
#endif
