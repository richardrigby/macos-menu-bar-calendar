import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    private var dateUpdateTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            updateMenuBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 340)
        popover.behavior = .transient
        popover.animates = true
        
        // Create hosting controller with transparent background
        let contentView = CalendarPopoverView(openSettings: openSettings)
            .background(VisualEffectBackground())
        let hostingController = NSHostingController(rootView: contentView)
        popover.contentViewController = hostingController
        
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
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    func openSettings() {
        popover.performClose(nil)
        
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
