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
    var colorHex: String           // A persistent color stored as a hex string

    init(name: String, weeklyGoalMinutes: Int = 0, colorHex: String? = nil) {
        self.id = UUID()
        self.name = name
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.dailyLogs = []
        // If a color is provided, use it; otherwise generate one.
        self.colorHex = colorHex ?? Category.randomColorHex()
    }
}

extension Category {
    /// A computed property that returns a Color using the stored hex value.
    var displayColor: Color {
        Color(hex: colorHex)
    }
    
    /// Returns a random color hex string from a fixed palette.
    static func randomColorHex() -> String {
        let colors = ["#FF6B6B", "#6BCB77", "#4D96FF", "#FFD93D", "#F97316", "#A78BFA"]
        return colors.randomElement() ?? "#FFFFFF"
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

struct CategorySelectionSheet: View {
    let categories: [Category]
    @Binding var selected: Category?
    @Binding var isPresented: Bool
    var onAddCategory: (String) -> Void
    var onDeleteCategory: (Category) -> Void

    var body: some View {
        NavigationView {
            List {
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
                    }
                }
            }
            .navigationBarTitle("Choose Topic", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}
