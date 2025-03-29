//
//  ModelMining.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import Foundation
import SwiftUI
import Combine

// A model representing a planet that can be mined.
struct Planet: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let baseMiningTime: Int    // Base mining time in seconds.
    let miningReward: Int      // Reward (e.g., coins) earned when mining completes.
    
    init(name: String, baseMiningTime: Int, miningReward: Int) {
        self.id = UUID()
        self.name = name
        self.baseMiningTime = baseMiningTime
        self.miningReward = miningReward
    }
}

class MiningModel: ObservableObject {
    // List of planets available to mine (earned from the study timer).
    @Published var availablePlanets: [Planet] = [
        // Sample planets. In your app, you'll add these dynamically.
        Planet(name: "Starter Planet", baseMiningTime: 1000, miningReward: 100),
    ]
    
    // Current mining state:
    @Published var currentMiningPlanet: Planet? = nil
    @Published var remainingTime: Int = 0  // in seconds
    
    // Private state for tracking mining progress.
    private var miningStartTime: Date?
    private var targetMiningDuration: Int = 0
    @Published var speedMultiplier: Int = 1  // 2 if focus mode, else 1
    
    private var miningTimer: Timer?
    
    /// Start mining a planet.
    /// - Parameters:
    ///   - planet: The planet to mine.
    ///   - inFocusMode: If true, mining goes twice as fast.
    func startMining(planet: Planet, inFocusMode: Bool) {
        // Only one planet can be mined at a time.
        guard currentMiningPlanet == nil else { return }
        currentMiningPlanet = planet
        // (Optionally, remove the planet from availablePlanets now or later.)
        speedMultiplier = inFocusMode ? 2 : 1
        targetMiningDuration = planet.baseMiningTime
        remainingTime = targetMiningDuration
        miningStartTime = Date()
        startMiningUITimer()
    }
    
    /// Starts a UI timer to update mining progress.
    private func startMiningUITimer() {
        miningTimer?.invalidate()
        miningTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateMiningProgress()
        }
    }
    
    /// Updates the remaining mining time based on elapsed time.
    func updateMiningProgress() {
        guard let start = miningStartTime, currentMiningPlanet != nil else { return }
        // Calculate elapsed time adjusted by the speed multiplier.
        let elapsed = Int(Date().timeIntervalSince(start)) * speedMultiplier
        let newRemaining = max(0, targetMiningDuration - elapsed)
        remainingTime = newRemaining
        
        if remainingTime <= 0 {
            finishMining()
        }
    }
    
    /// Completes the mining process, awarding the reward.
    func finishMining() {
        if let planet = currentMiningPlanet {
            // In a complete app, you would pass the reward to the CurrencyModel.
            // For now, you might post a notification or directly call currencyModel.earn(amount: planet.miningReward)
            // For demonstration, we'll just print the reward.
            print("Finished mining \(planet.name)! Awarding \(planet.miningReward) coins.")
        }
        resetMiningState()
    }
    
    /// Cancels the current mining operation.
    func cancelMining() {
        resetMiningState()
    }
    
    
    /// Refreshes mining progress (useful when app returns to active state).
    func refreshMiningProgress() {
        if currentMiningPlanet != nil {
            updateMiningProgress()
        }
    }
    
    /// Resets the mining state.
    private func resetMiningState() {
        miningTimer?.invalidate()
        miningTimer = nil
        currentMiningPlanet = nil
        miningStartTime = nil
        targetMiningDuration = 0
        remainingTime = 0
    }
}
