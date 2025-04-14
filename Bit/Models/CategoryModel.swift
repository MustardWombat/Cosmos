//
//  Category.swift
//  Cosmos
//
//  Created by James Williams on 3/25/25.
//

import SwiftUI
import Foundation

class Category: ObservableObject, Identifiable, Codable, Hashable {
    var id: UUID
    @Published var name: String
    @Published var weeklyGoalMinutes: Int     // How many minutes per week the user aims for
    @Published var dailyLogs: [DailyLog]        // Each day’s study minutes
    var colorHex: String                        // A persistent color stored as a hex string

    init(name: String, weeklyGoalMinutes: Int = 0, colorHex: String? = nil) {
        self.id = UUID()
        self.name = name
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.dailyLogs = []
        self.colorHex = colorHex ?? Category.randomColorHex()
    }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case id, name, weeklyGoalMinutes, dailyLogs, colorHex
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        weeklyGoalMinutes = try container.decode(Int.self, forKey: .weeklyGoalMinutes)
        dailyLogs = try container.decode([DailyLog].self, forKey: .dailyLogs)
        colorHex = try container.decode(String.self, forKey: .colorHex)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(weeklyGoalMinutes, forKey: .weeklyGoalMinutes)
        try container.encode(dailyLogs, forKey: .dailyLogs)
        try container.encode(colorHex, forKey: .colorHex)
    }

    // MARK: - Computed properties
    var displayColor: Color {
        Color(hex: colorHex)
    }
    
    var weeklyLogs: [DailyLog] {
        let now = Date()
        let calendar = Calendar.current
        var results: [DailyLog] = []

        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -offset, to: now) {
                let dayStart = calendar.startOfDay(for: day)
                if let log = dailyLogs.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
                    results.append(DailyLog(date: dayStart, minutes: log.minutes))
                } else {
                    results.append(DailyLog(date: dayStart, minutes: 0))
                }
            }
        }
        return results.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper
    static func randomColorHex() -> String {
        let colors = ["#FF6B6B", "#6BCB77", "#4D96FF", "#FFD93D", "#F97316", "#A78BFA"]
        return colors.randomElement() ?? "#FFFFFF"
    }
    
    // For Hashable conformance
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// A simple extension to create a Color from a hex string.
extension Color {
    init(hex: String) {
        // Trim the hash if present
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let r, g, b: UInt64
        if hexString.count == 6 {
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        } else {
            r = 255
            g = 255
            b = 255
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

// A simple struct for logging minutes studied on a given date.
struct DailyLog: Identifiable, Codable, Hashable {
    let id = UUID()
    var date: Date
    var minutes: Int
}

// Function to update daily logs for a category
func updateDailyLogs(for categories: [Category], categoryID: UUID, date: Date, minutes: Int) {
    guard let category = categories.first(where: { $0.id == categoryID }) else { return }
    let calendar = Calendar.current

    // Force an update notification for deep changes.
    category.objectWillChange.send()

    if let logIndex = category.dailyLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
        category.dailyLogs[logIndex].minutes += minutes
    } else {
        let newLog = DailyLog(date: date, minutes: minutes)
        category.dailyLogs.append(newLog)
    }
}

struct CategorySelectionSheet: View {
    let categories: [Category]
    @Binding var selected: Category?
    @Binding var isPresented: Bool
    var onAddCategory: (String) -> Void
    var onDeleteCategory: (Category) -> Void

    @State private var showDeleteAlert = false
    @State private var categoryToDelete: Category?
    @State private var newCategoryName: String = ""
    @State private var showCreateAlert = false

    var body: some View {
        NavigationView {
            List {
                // Create New Topic Button
                Button(action: {
                    showCreateAlert = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Create New Topic")
                            .foregroundColor(.blue)
                    }
                }

                // List of categories
                ForEach(categories) { category in
                    Button(action: {
                        selected = category // Update the selected binding
                        isPresented = false
                    }) {
                        HStack {
                            Circle()
                                .fill(category.displayColor)
                                .frame(width: 12, height: 12)
                            Text(category.name)
                            Spacer()
                            if selected?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle()) // Makes the entire row tappable
                    }
                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                        categoryToDelete = category
                        showDeleteAlert = true
                    })
                }
            }
            .navigationBarTitle("Choose Topic", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Topic"),
                    message: Text("Are you sure you want to delete '\(categoryToDelete?.name ?? "")'?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let category = categoryToDelete {
                            onDeleteCategory(category)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Create New Topic", isPresented: $showCreateAlert, actions: {
                TextField("Topic Name", text: $newCategoryName)
                Button("Create") {
                    let trimmedName = newCategoryName.trimmingCharacters(in: .whitespaces)
                    guard !trimmedName.isEmpty else { return }
                    onAddCategory(trimmedName)
                    newCategoryName = "" // Clear the input field
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Enter a name for your new topic.")
            })
        }
    }
}
