import Foundation
import Combine
import SwiftUI

#if os(iOS)
import UIKit
#endif

class StudyTimerModel: ObservableObject {
    @Published var earnedRewards: [String] = [] {
        didSet { saveData() }
    }
    @Published var timeRemaining: Int = 0
    @Published var isTimerRunning: Bool = false
    @Published var totalTimeStudied: Int = 0 {
        didSet { saveData() }
    }
    @Published var reward: String? = nil
    @Published var isFocusCheckActive: Bool = false
    @Published var focusStreak: Int = 0 {
        didSet { saveData() }
    }

    var xpModel: XPModel?
    var miningModel: MiningModel? // Injected mining model

    private var timer: Timer?
    private var timerStartDate: Date?
    private var initialDuration: Int = 0
    private let studyDataKey = "StudyTimerModelData"

    #if os(iOS)
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    #endif

    // MARK: - Init
    init(xpModel: XPModel? = nil, miningModel: MiningModel? = nil) {
        self.xpModel = xpModel
        self.miningModel = miningModel
        loadData()
    }

    // MARK: - Timer Start
    func startTimer(for duration: Int) {
        let maxDuration = 3600 // 1 hour

        if isTimerRunning {
            initialDuration += duration
            initialDuration = min(initialDuration, maxDuration)
            if let start = timerStartDate {
                let elapsed = Int(Date().timeIntervalSince(start))
                timeRemaining = max(0, initialDuration - elapsed)
            }
        } else {
            initialDuration = min(duration, maxDuration)
            timerStartDate = Date()
            timeRemaining = initialDuration
            isTimerRunning = true
            reward = nil

            #if os(iOS)
            backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "StudyTimer") {
                self.endBackgroundTask()
            }
            #endif

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimeRemaining()
            }
        }
    }

    // MARK: - Timer Update
    func updateTimeRemaining() {
        guard let start = timerStartDate else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        let newRemaining = max(0, initialDuration - elapsed)
        DispatchQueue.main.async { self.timeRemaining = newRemaining }
        if newRemaining <= 0 {
            stopTimer()
        }
    }

    // MARK: - Timer Stop
    func stopTimer() {
        let studiedTime = initialDuration - timeRemaining
        timer?.invalidate()
        timer = nil
        isTimerRunning = false

        print("Adding \(studiedTime) XP")
        xpModel?.addXP(studiedTime)

        if studiedTime >= 300 {
            calculateReward()
        }

        endBackgroundTask()
    }

    // MARK: - Reward Logic with MiningModel
    func calculateReward() {
        let studiedTime = initialDuration - timeRemaining
        totalTimeStudied += studiedTime

        var planetType: PlanetType

        if studiedTime >= 1800 {
            planetType = .rare
        } else if studiedTime >= 900 {
            planetType = .common
        } else {
            planetType = .tiny
        }

        reward = planetType.rawValue
        earnedRewards.append(planetType.rawValue)

        if let planet = miningModel?.getPlanet(ofType: planetType) {
            miningModel?.availablePlanets.append(planet)
            print("🪐 Added planet: \(planet.name)")
        }
    }

    // MARK: - Harvest Coins
    func harvestRewards() -> Int {
        let rewardValue = earnedRewards.reduce(0) { total, reward in
            switch reward {
            case PlanetType.rare.rawValue: return total + 50
            case PlanetType.common.rawValue: return total + 20
            case PlanetType.tiny.rawValue: return total + 5
            default: return total
            }
        }
        earnedRewards.removeAll()
        return rewardValue
    }

    // MARK: - Background Task (iOS only)
    #if os(iOS)
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    #else
    private func endBackgroundTask() {}
    #endif

    // MARK: - Focus Check
    func triggerFocusCheck() {
        isFocusCheckActive = true
    }

    func handleFocusAnswer(yes: Bool) {
        if yes {
            focusStreak += 1
        } else {
            focusStreak = 0
            stopTimer()
        }
        isFocusCheckActive = false
    }

    // MARK: - Persistence
    private func saveData() {
        let data: [String: Any] = [
            "earnedRewards": earnedRewards,
            "totalTimeStudied": totalTimeStudied,
            "focusStreak": focusStreak
        ]
        UserDefaults.standard.set(data, forKey: studyDataKey)
    }

    private func loadData() {
        if let data = UserDefaults.standard.dictionary(forKey: studyDataKey) {
            earnedRewards = data["earnedRewards"] as? [String] ?? []
            totalTimeStudied = data["totalTimeStudied"] as? Int ?? 0
            focusStreak = data["focusStreak"] as? Int ?? 0
        }
    }
}

// MARK: - Utility
extension StudyTimerModel {
    var studiedMinutes: Int {
        if let _ = timerStartDate {
            return (initialDuration - timeRemaining) / 60
        }
        return 0
    }
}
