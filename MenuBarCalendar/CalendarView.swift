import SwiftUI
import AppKit

struct CalendarPopoverView: View {
    @StateObject private var settings = SettingsManager.shared
    @State private var currentDate = Date()
    let openSettings: () -> Void
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    private let daysOfWeekSunday = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 12) {            
            // Header with navigation and settings
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                
                Button(action: jumpToToday) {
                    Image(systemName: "calendar.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .help("Go to today")
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: openSettings) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 8)
            
            Spacer()

            // Days of week header
            HStack(spacing: 0) {
                if settings.showWeekNumbers {
                    Text("")
                        .frame(width: 28)
                }
                
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
            
            // Calendar grid
            let weeks = generateWeeks()
            VStack(spacing: 4) {
                ForEach(weeks.indices, id: \.self) { weekIndex in
                    HStack(spacing: 0) {
                        if settings.showWeekNumbers {
                            Text("\(weekNumber(for: weeks[weekIndex]))")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .frame(width: 28)
                        }
                        
                        ForEach(weeks[weekIndex].indices, id: \.self) { dayIndex in
                            let dayInfo = weeks[weekIndex][dayIndex]
                            DayCell(dayInfo: dayInfo)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(width: 300, height: 340)
    }
    
    private var weekDays: [String] {
        settings.firstDayOfWeek == .monday ? daysOfWeek : daysOfWeekSunday
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
    }
    
    private func jumpToToday() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentDate = Date()
        }
    }
    
    private func weekNumber(for week: [DayInfo]) -> Int {
        // Find the first valid date in the week
        for day in week {
            if day.isCurrentMonth {
                return calendar.component(.weekOfYear, from: day.date)
            }
        }
        // Fallback: use the middle day
        if week.count > 3 {
            return calendar.component(.weekOfYear, from: week[3].date)
        }
        return 0
    }
    
    private func generateWeeks() -> [[DayInfo]] {
        var weeks: [[DayInfo]] = []
        
        // Get the first day of the month
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstOfMonth = calendar.date(from: components) else { return weeks }
        
        // Get the range of days in the month
        guard let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return weeks }
        
        // Get the weekday of the first day (1 = Sunday, 2 = Monday, ...)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        // Calculate offset based on first day of week setting
        let startOffset: Int
        if settings.firstDayOfWeek == .monday {
            startOffset = (firstWeekday + 5) % 7 // Monday = 0
        } else {
            startOffset = firstWeekday - 1 // Sunday = 0
        }
        
        // Get today's date for comparison
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        var currentWeek: [DayInfo] = []
        
        // Add days from previous month
        if startOffset > 0 {
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth),
                  let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth) else { return weeks }
            
            let previousMonthDays = previousMonthRange.count
            for i in 0..<startOffset {
                let day = previousMonthDays - startOffset + i + 1
                if let date = calendar.date(byAdding: .day, value: -startOffset + i, to: firstOfMonth) {
                    currentWeek.append(DayInfo(day: day, date: date, isCurrentMonth: false, isToday: false))
                }
            }
        }
        
        // Add days of current month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let isToday = dateComponents.year == todayComponents.year &&
                              dateComponents.month == todayComponents.month &&
                              dateComponents.day == todayComponents.day
                
                currentWeek.append(DayInfo(day: day, date: date, isCurrentMonth: true, isToday: isToday))
                
                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    currentWeek = []
                }
            }
        }
        
        // Add days from next month
        if !currentWeek.isEmpty {
            let remainingDays = 7 - currentWeek.count
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth) else { return weeks }
            
            for day in 1...remainingDays {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: nextMonth) {
                    currentWeek.append(DayInfo(day: day, date: date, isCurrentMonth: false, isToday: false))
                }
            }
            weeks.append(currentWeek)
        }
        
        // Ensure we always have 6 weeks for consistent height
        while weeks.count < 6 {
            var nextWeek: [DayInfo] = []
            let lastWeek = weeks.last!
            let lastDate = lastWeek.last!.date
            
            for i in 1...7 {
                if let date = calendar.date(byAdding: .day, value: i, to: lastDate) {
                    let day = calendar.component(.day, from: date)
                    nextWeek.append(DayInfo(day: day, date: date, isCurrentMonth: false, isToday: false))
                }
            }
            weeks.append(nextWeek)
        }
        
        return weeks
    }
}

struct DayInfo {
    let day: Int
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
}

struct DayCell: View {
    let dayInfo: DayInfo
    
    var body: some View {
        ZStack {
            if dayInfo.isToday {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 28, height: 28)
            }
            
            Text("\(dayInfo.day)")
                .font(.system(size: 14, weight: dayInfo.isToday ? .semibold : .regular))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }
    
    private var textColor: Color {
        if dayInfo.isToday {
            return .white
        } else if dayInfo.isCurrentMonth {
            return .primary
        } else {
            return .secondary.opacity(0.5)
        }
    }
}

#Preview {
    CalendarPopoverView(openSettings: {})
}
