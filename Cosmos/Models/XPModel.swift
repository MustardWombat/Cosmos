//
//  XPModel.swift
//  Cosmos
//
//  Created by James Williams on 4/1/25.
//

import Foundation
import SwiftUI
import Combine

class XPModel: ObservableObject {
    @Published var xp: Int = 0           // Current XP
    @Published var level: Int = 1        // Current Level
    @Published var xpForNextLevel: Int = 100  // XP required for next level
    @Published var upgradeMultiplier: Double = 1.0  // XP gain multiplier from upgrades
    
    /// Adds XP to the system, applying the upgrade multiplier.
    func addXP(_ amount: Int) {
        // Apply the multiplier to the XP gain
            let effectiveXP = Int(Double(amount) * upgradeMultiplier)
        xp += effectiveXP
        print("Current XP:", xp)
        checkForLevelUp()
    }
    
    /// Checks whether the current XP meets or exceeds the threshold for leveling up.
    private func checkForLevelUp() {
        // Loop in case the XP is enough for multiple level-ups at once.
        while xp >= xpForNextLevel {
            xp -= xpForNextLevel
            level += 1
            xpForNextLevel = calculateXPForNextLevel(for: level)
            // You can also trigger a level-up event or animation here.
            print("Leveled up! New level: \(level)")
        }
    }
    
    /// Calculate the required XP for the next level.
    /// For example, this quadratic formula increases XP requirement as level rises.
    private func calculateXPForNextLevel(for level: Int) -> Int {
        return 100 * level * level
    }
    
    /// Upgrade the XP multiplier (e.g., from purchasing an upgrade)
    func applyUpgrade(multiplier: Double) {
        upgradeMultiplier *= multiplier
    }
    
    /// Optionally, reset XP (or this could be used in a prestige/reset system).
    func resetXP() {
        xp = 0
        level = 1
        xpForNextLevel = 100
        upgradeMultiplier = 1.0
    }
}
struct XPDisplayView: View {
    @EnvironmentObject var xpModel: XPModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Level: \(xpModel.level)")
                .foregroundColor(.white)
            ProgressView(value: Double(xpModel.xp), total: Double(xpModel.xpForNextLevel))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            Text("\(xpModel.xp) / \(xpModel.xpForNextLevel) XP")
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}
