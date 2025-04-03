import Foundation
import SwiftUI
import Combine

struct Planet: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let baseMiningTime: Int    // in seconds
    let miningReward: Int      // coins earned when mining completes
    var miningStartDate: Date? = nil  // when mining started

    init(id: UUID = UUID(), name: String, baseMiningTime: Int, miningReward: Int, miningStartDate: Date? = nil) {
        self.id = id
        self.name = name
        self.baseMiningTime = baseMiningTime
        self.miningReward = miningReward
        self.miningStartDate = miningStartDate
    }
}

class MiningModel: ObservableObject {
    @Published var availablePlanets: [Planet] = [
        Planet(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Starter Planet",
            baseMiningTime: 10,
            miningReward: 100
        )
    ]
    
    @Published var currentMiningPlanet: Planet? = nil
    @Published var miningProgress: Double = 0.0   // 0.0 to 1.0
    @Published var speedMultiplier: Int = 1

    private var miningTimer: Timer?
    private var miningStartTime: Date?
    private var targetMiningDuration: Int = 0

    private let savedMiningKey = "currentMiningPlanetData"

    // MARK: - Start Mining

    func startMining(planet: Planet, inFocusMode: Bool) {
        guard currentMiningPlanet == nil else { return }
        
        var updatedPlanet = planet
        updatedPlanet.miningStartDate = Date()
        
        // Remove from list so we don’t show a duplicate.
        availablePlanets.removeAll { $0.id == planet.id }
        
        currentMiningPlanet = updatedPlanet
        speedMultiplier = inFocusMode ? 2 : 1
        targetMiningDuration = updatedPlanet.baseMiningTime
        miningStartTime = updatedPlanet.miningStartDate
        miningProgress = 0.0
        
        saveCurrentMiningState()
        startMiningUITimer()
    }
    
    private func startMiningUITimer() {
        miningTimer?.invalidate()
        miningTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateMiningProgress()
        }
    }
    
    // MARK: - Update Progress
    
    func updateMiningProgress() {
        guard let start = miningStartTime, currentMiningPlanet != nil else { return }
        let elapsed = Date().timeIntervalSince(start) * Double(speedMultiplier)
        let progress = elapsed / Double(targetMiningDuration)
        miningProgress = min(progress, 1.0)
        
        if miningProgress >= 1.0 {
            finishMining()
        }
    }
    
    func refreshMiningProgress() {
        if currentMiningPlanet != nil {
            updateMiningProgress()
        }
    }
    
    // MARK: - Resume on Launch
    
    func resumeMiningIfNeeded() {
        restoreSavedMiningState()
    }
    
    func restoreSavedMiningState() {
        guard let data = UserDefaults.standard.data(forKey: savedMiningKey) else { return }
        do {
            let planet = try JSONDecoder().decode(Planet.self, from: data)
            currentMiningPlanet = planet
            miningStartTime = planet.miningStartDate
            targetMiningDuration = planet.baseMiningTime
            updateMiningProgress()
            startMiningUITimer()
        } catch {
            print("❌ Failed to load mining state: \(error)")
        }
    }
    
    private func saveCurrentMiningState() {
        guard let planet = currentMiningPlanet else { return }
        do {
            let data = try JSONEncoder().encode(planet)
            UserDefaults.standard.set(data, forKey: savedMiningKey)
        } catch {
            print("❌ Failed to save mining state: \(error)")
        }
    }
    
    private func clearSavedMiningState() {
        UserDefaults.standard.removeObject(forKey: savedMiningKey)
    }
    
    // MARK: - Finish Mining
    
    func finishMining() {
        if let planet = currentMiningPlanet {
            print("⛏️ Finished mining \(planet.name)! Awarding \(planet.miningReward) coins.")
            // Re-add the planet after mining completes.
            availablePlanets.append(planet)
        }
        clearSavedMiningState()
        resetMiningState()
    }
    
    // We now disable cancellation per your request.
    func cancelMining() {
        // Not allowed.
    }
    
    private func resetMiningState() {
        miningTimer?.invalidate()
        miningTimer = nil
        currentMiningPlanet = nil
        miningStartTime = nil
        targetMiningDuration = 0
        miningProgress = 0.0
    }
}
extension MiningModel {
    func addPlanet(for reward: String) {
        var newPlanet: Planet?
        
        switch reward {
        case "🌟 Rare Planet":
            newPlanet = Planet(name: "Rare Planet", baseMiningTime: 120, miningReward: 50)
        case "🌕 Common Planet":
            newPlanet = Planet(name: "Common Planet", baseMiningTime: 90, miningReward: 20)
        case "🌑 Tiny Asteroid":
            newPlanet = Planet(name: "Tiny Asteroid", baseMiningTime: 60, miningReward: 5)
        default:
            break
        }
        
        if let planet = newPlanet {
            availablePlanets.append(planet)
            print("Added new planet: \(planet.name)")
        }
    }
}
