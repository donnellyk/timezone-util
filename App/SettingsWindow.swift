import AppKit
import SwiftUI

/// A titled floating window that hosts SwiftUI content and follows an `isPresented`
/// binding. A menu-bar app has no main window, so the menu-bar label owns this one;
/// floating keeps it reachable without a Dock icon.
final class SettingsWindow<Content: View>: NSPanel, NSWindowDelegate {
    private let isPresented: Binding<Bool>

    init(size: CGSize, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        title = "Zones Settings"
        isFloatingPanel = true
        level = .floating
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        contentView = NSHostingView(rootView: content())
        center()
        delegate = self
    }

    func present() {
        NSApp.activate()
        makeKeyAndOrderFront(nil)
        orderFrontRegardless()
    }

    // Close button: keep the binding in sync.
    func windowWillClose(_ notification: Notification) {
        if isPresented.wrappedValue { isPresented.wrappedValue = false }
    }

    override var canBecomeKey: Bool { true }
}

private struct SettingsWindowModifier<WindowContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let size: CGSize
    @ViewBuilder let windowContent: () -> WindowContent

    @State private var window: SettingsWindow<WindowContent>?

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { _, presented in
            let window =
                window
                ?? SettingsWindow(size: size, isPresented: $isPresented, content: windowContent)
            self.window = window
            if presented { window.present() } else { window.orderOut(nil) }
        }
    }
}

extension View {
    func settingsWindow<Content: View>(
        isPresented: Binding<Bool>, size: CGSize, @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            SettingsWindowModifier(isPresented: isPresented, size: size, windowContent: content))
    }
}
