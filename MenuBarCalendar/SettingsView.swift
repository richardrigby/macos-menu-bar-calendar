import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    @State private var launchAtLogin = false
    
    var body: some View {
        VStack(spacing: 0) {
            // General Settings Section
            GroupBox {
                VStack(spacing: 12) {
                    HStack {
                        Text("Launch at login")
                        Spacer()
                        Toggle("", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .onChange(of: launchAtLogin) { newValue in
                                setLaunchAtLogin(enabled: newValue)
                            }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("First day of week")
                        Spacer()
                        Picker("", selection: $settings.firstDayOfWeek) {
                            Text("Sunday").tag(FirstDayOfWeek.sunday)
                            Text("Monday").tag(FirstDayOfWeek.monday)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Display Settings Section
            GroupBox {
                VStack(spacing: 12) {
                    HStack {
                        Text("Menu bar icon")
                        Spacer()
                        Picker("", selection: $settings.useCalendarIcon) {
                            Image(systemName: "calendar")
                                .tag(true)
                            Text("30")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                        .onChange(of: settings.useCalendarIcon) { _ in
                            refreshMenuBarIcon()
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Show week numbers")
                        Spacer()
                        Toggle("", isOn: $settings.showWeekNumbers)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Keyboard Shortcut Section (placeholder for future)
            GroupBox {
                HStack {
                    Text("Toggle calendar")
                    Spacer()
                    Button("Record Shortcut") {
                        // Future: implement keyboard shortcut recording
                    }
                    .buttonStyle(.bordered)
                    .disabled(true)
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
            
            // Footer
            HStack {
                Text("Menu Bar Calendar v1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 280)
        .onAppear {
            checkLaunchAtLogin()
        }
    }
    
    private func checkLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }
    
    private func refreshMenuBarIcon() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.refreshMenuBarIcon()
        }
    }
}

#Preview {
    SettingsView()
}
