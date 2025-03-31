//
//  Category.swift
//  Cosmos
//
//  Created by James Williams on 3/25/25.
//

import SwiftUI
import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var weeklyGoalMinutes: Int     // How many minutes per week the user aims for
    var dailyLogs: [DailyLog]      // Each day’s study minutes

    init(name: String, weeklyGoalMinutes: Int = 0) {
        self.id = UUID()
        self.name = name
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.dailyLogs = []
    }

    /// Returns a Color determined by the hash of the category's name.
    var displayColor: Color {
        let hash = abs(name.hashValue)
        let red = Double((hash >> 16) & 0xFF) / 255.0
        let green = Double((hash >> 8) & 0xFF) / 255.0
        let blue = Double(hash & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}

// A simple struct for logging minutes studied on a given date.
struct DailyLog: Identifiable, Codable, Hashable {
    let id = UUID()
    var date: Date
    var minutes: Int
}
