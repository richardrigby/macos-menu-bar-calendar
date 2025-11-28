import SwiftUI
import Combine

enum FirstDayOfWeek: Int, CaseIterable {
    case sunday = 0
    case monday = 1
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let firstDayOfWeek = "firstDayOfWeek"
        static let useCalendarIcon = "useCalendarIcon"
        static let showWeekNumbers = "showWeekNumbers"
    }
    
    @Published var firstDayOfWeek: FirstDayOfWeek {
        didSet {
            defaults.set(firstDayOfWeek.rawValue, forKey: Keys.firstDayOfWeek)
        }
    }
    
    @Published var useCalendarIcon: Bool {
        didSet {
            defaults.set(useCalendarIcon, forKey: Keys.useCalendarIcon)
        }
    }
    
    @Published var showWeekNumbers: Bool {
        didSet {
            defaults.set(showWeekNumbers, forKey: Keys.showWeekNumbers)
        }
    }
    
    private init() {
        // Load saved settings or use defaults
        let savedFirstDay = defaults.integer(forKey: Keys.firstDayOfWeek)
        self.firstDayOfWeek = FirstDayOfWeek(rawValue: savedFirstDay) ?? .monday
        
        // Default to calendar icon style
        if defaults.object(forKey: Keys.useCalendarIcon) == nil {
            self.useCalendarIcon = true
        } else {
            self.useCalendarIcon = defaults.bool(forKey: Keys.useCalendarIcon)
        }
        
        // Default to not showing week numbers
        self.showWeekNumbers = defaults.bool(forKey: Keys.showWeekNumbers)
    }
}
