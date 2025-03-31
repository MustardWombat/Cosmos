import Foundation
import SwiftUI

private let selectedTopicKey = "selectedTopicID"

class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = [] {
        didSet {
            saveCategories()
        }
    }

    private let storageKey = "savedCategories"

    init() {
        loadCategories()
    }

    // Add a new category
    func addCategory(name: String, weeklyGoalMinutes: Int = 0) {
        let newCat = Category(name: name, weeklyGoalMinutes: weeklyGoalMinutes)
        categories.append(newCat)
    }

    // Log study time for a specific category and date.
    func logStudyTime(categoryID: UUID, date: Date, minutes: Int) {
        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else { return }

        let calendar = Calendar.current
        var updatedCategory = categories[index]

        if let logIndex = updatedCategory.dailyLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            updatedCategory.dailyLogs[logIndex].minutes += minutes
        } else {
            let newLog = DailyLog(date: date, minutes: minutes)
            updatedCategory.dailyLogs.append(newLog)
        }

        categories[index] = updatedCategory
        saveCategories()
    }

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

    // MARK: - Selected Topic Persistence ✅
    func saveSelectedTopicID(_ id: UUID?) {
        if let id = id {
            UserDefaults.standard.set(id.uuidString, forKey: selectedTopicKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedTopicKey)
        }
    }

    func loadSelectedTopic() -> Category? {
        guard let savedID = UserDefaults.standard.string(forKey: selectedTopicKey),
              let uuid = UUID(uuidString: savedID) else { return nil }

        return categories.first(where: { $0.id == uuid })
    }

    // MARK: - Category Persistence
    private func saveCategories() {
        do {
            let data = try JSONEncoder().encode(categories)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save categories: \(error)")
        }
    }

    private func loadCategories() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            categories = try JSONDecoder().decode([Category].self, from: data)
        } catch {
            print("Failed to load categories: \(error)")
        }
    }
}
