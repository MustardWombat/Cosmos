import Foundation
import SwiftUI

class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    // Add a new category
    func addCategory(name: String, weeklyGoalMinutes: Int = 0) {
        let newCat = Category(name: name, weeklyGoalMinutes: weeklyGoalMinutes)
        categories.append(newCat)
    }
    
    // Log study time for a specific category and date.
    func logStudyTime(categoryID: UUID, date: Date, minutes: Int) {
        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        
        let calendar = Calendar.current
        // Check if there's already a log for the given date.
        if let logIndex = categories[index].dailyLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            categories[index].dailyLogs[logIndex].minutes += minutes
        } else {
            let newLog = DailyLog(date: date, minutes: minutes)
            categories[index].dailyLogs.append(newLog)
        }
    }
    
    // Returns daily logs for the past 7 days (example implementation)
    func weeklyData(for categoryID: UUID) -> [DailyLog] {
        guard let category = categories.first(where: { $0.id == categoryID }) else { return [] }
        
        let now = Date()
        let calendar = Calendar.current
        var results: [DailyLog] = []
        
        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -offset, to: now) {
                let dayStart = calendar.startOfDay(for: day)
                if let log = category.dailyLogs.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
                    results.append(DailyLog(date: dayStart, minutes: log.minutes))
                } else {
                    results.append(DailyLog(date: dayStart, minutes: 0))
                }
            }
        }
        return results.sorted { $0.date < $1.date }
    }
}
