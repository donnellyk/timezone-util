import AppKit
import SwiftUI

/// A chromeless floating panel under the menu-bar icon, for showing the menu's content
/// from the global shortcut. SwiftUI cannot open a `MenuBarExtra` window from code.
/// Esc or a click elsewhere dismisses it through the `isPresented` binding.
final class ZonesPanel<Content: View>: NSPanel, NSWindowDelegate {
    private let isPresented: Binding<Bool>
    private var previousApp: NSRunningApplication?

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        super.init(
            contentRect: .zero, styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered, defer: false)
        isFloatingPanel = true
        level = .floating
        collectionBehavior.insert(.fullScreenAuxiliary)
        animationBehavior = .utilityWindow
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        // Transparent window so the SwiftUI glass provides the shape.
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        [.closeButton, .miniaturizeButton, .zoomButton].forEach {
            standardWindowButton($0)?.isHidden = true
        }
        contentView = NSHostingView(rootView: content().ignoresSafeArea())
        delegate = self
    }

    func present() {
        previousApp = NSWorkspace.shared.frontmostApplication
        if previousApp?.bundleIdentifier == Bundle.main.bundleIdentifier { previousApp = nil }
        let size = contentView?.fittingSize ?? frame.size
        setFrame(NSRect(origin: origin(for: size), size: size), display: false)
        NSApp.activate()
        makeKeyAndOrderFront(nil)
        orderFrontRegardless()
    }

    func dismiss() {
        orderOut(nil)
        // Only hand focus back on an explicit dismiss (our app still frontmost); if the
        // user switched apps, leave focus where they put it.
        if NSApp.isActive, let app = previousApp { app.activate(options: []) }
        previousApp = nil
    }

    /// Just below the menu-bar icon, kept on screen; centered when the icon's window
    /// can't be found.
    private func origin(for size: NSSize) -> NSPoint {
        let anchor = NSApp.windows.first { $0.className == "NSStatusBarWindow" }?.frame
        let screen = anchor.flatMap { anchor in
            NSScreen.screens.first { $0.frame.intersects(anchor) }
        }
        let visible = (screen ?? NSScreen.main)?.visibleFrame ?? .zero
        guard let anchor else {
            return NSPoint(x: visible.midX - size.width / 2, y: visible.midY - size.height / 2)
        }
        let x = min(
            max(anchor.midX - size.width / 2, visible.minX + 8), visible.maxX - size.width - 8)
        return NSPoint(x: x, y: anchor.minY - 6 - size.height)
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown, event.keyCode == 53 {
            isPresented.wrappedValue = false
            return
        }
        super.sendEvent(event)
    }

    func windowDidResignKey(_ notification: Notification) {
        guard isVisible, isPresented.wrappedValue else { return }
        isPresented.wrappedValue = false
    }

    override var canBecomeKey: Bool { true }
}

private struct ZonesPanelModifier<PanelContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let panelContent: () -> PanelContent

    @State private var panel: ZonesPanel<PanelContent>?

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { _, presented in
            let panel = panel ?? ZonesPanel(isPresented: $isPresented, content: panelContent)
            self.panel = panel
            if presented { panel.present() } else { panel.dismiss() }
        }
    }
}

extension View {
    func zonesPanel<Content: View>(
        isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ZonesPanelModifier(isPresented: isPresented, panelContent: content))
    }
}
