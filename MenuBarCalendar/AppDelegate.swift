import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var calendarPanel: NSPanel?
    private var settingsWindow: NSWindow?
    private var dateUpdateTimer: Timer?
    private var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            updateMenuBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create the calendar panel (no arrow, flat top like native macOS panels)
        createCalendarPanel()
        
        // Set up timer to update the date at midnight
        scheduleNextDayUpdate()
        
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func updateMenuBarIcon() {
        if let button = statusItem.button {
            let day = Calendar.current.component(.day, from: Date())
            
            if SettingsManager.shared.useCalendarIcon {
                // Use calendar icon with date
                button.image = createCalendarIcon(day: day)
                button.title = ""
            } else {
                // Use just the date number
                button.image = nil
                button.title = "\(day)"
                button.font = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
            }
        }
    }
    
    private func createCalendarIcon(day: Int) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw calendar outline
        let rect = NSRect(x: 1, y: 1, width: 16, height: 16)
        let path = NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2)
        NSColor.labelColor.setStroke()
        path.lineWidth = 1.0
        path.stroke()
        
        // Draw top bar
        let topBarRect = NSRect(x: 1, y: 12, width: 16, height: 5)
        let topPath = NSBezierPath(roundedRect: topBarRect, xRadius: 2, yRadius: 2)
        NSColor.labelColor.setFill()
        topPath.fill()
        
        // Draw day number
        let dayString = "\(day)"
        let font = NSFont.systemFont(ofSize: 9, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor
        ]
        let textSize = dayString.size(withAttributes: attributes)
        let textPoint = NSPoint(
            x: (size.width - textSize.width) / 2,
            y: 2
        )
        dayString.draw(at: textPoint, withAttributes: attributes)
        
        image.unlockFocus()
        image.isTemplate = true
        
        return image
    }
    
    private func scheduleNextDayUpdate() {
        // Cancel existing timer
        dateUpdateTimer?.invalidate()
        
        // Calculate time until next midnight
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
           let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 1, of: tomorrow) {
            let timeInterval = midnight.timeIntervalSince(Date())
            
            dateUpdateTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                self?.updateMenuBarIcon()
                self?.scheduleNextDayUpdate()
            }
        }
    }
    
    private func createCalendarPanel() {
        let contentView = CalendarPopoverView(openSettings: openSettings)
        let hostingController = NSHostingController(rootView: contentView)
        
        // Create a visual effect view as the base
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 0
        visualEffectView.layer?.masksToBounds = true
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 340),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Set the visual effect view as the content view
        panel.contentView = visualEffectView
        
        // Add the SwiftUI hosting view on top
        let hostingView = hostingController.view
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor)
        ])
        
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        
        calendarPanel = panel
    }
    
    @objc func togglePopover() {
        guard let panel = calendarPanel else { return }
        
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    private func showPanel() {
        guard let panel = calendarPanel, let button = statusItem.button else { return }
        
        // Get the button's position on screen
        guard let buttonWindow = button.window else { return }
        let buttonRect = button.convert(button.bounds, to: nil)
        let screenRect = buttonWindow.convertToScreen(buttonRect)
        
        // Position the panel below the menu bar button, centered
        let panelWidth: CGFloat = 300
        let panelHeight: CGFloat = 340
        let panelX = screenRect.midX - (panelWidth / 2)
        let panelY = screenRect.minY - panelHeight - 7 // 7pt gap below menu bar
        
        panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
        panel.makeKeyAndOrderFront(nil)
        
        // Add event monitor to close panel when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.hidePanel()
        }
    }
    
    private func hidePanel() {
        calendarPanel?.orderOut(nil)
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    func openSettings() {
        hidePanel()
        
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            
            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "Menu Bar Calendar Settings"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.setContentSize(NSSize(width: 400, height: 280))
            settingsWindow?.center()
            settingsWindow?.isReleasedWhenClosed = false
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func refreshMenuBarIcon() {
        updateMenuBarIcon()
    }
}
