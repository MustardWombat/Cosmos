//
//  StudyTimerModel.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import Foundation
import Combine
import SwiftUI

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
    
    private var timer: Timer?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var timerStartDate: Date?
    private var initialDuration: Int = 0
    private let studyDataKey = "StudyTimerModelData"
    
    init() {
        loadData()
    }
    
    func startTimer(for duration: Int) {
        let maxDuration = 3600  // 1 hour
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
            
            backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "StudyTimer") {
                self.endBackgroundTask()
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimeRemaining()
            }
        }
    }
    
    func updateTimeRemaining() {
        guard let start = timerStartDate else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        let newRemaining = max(0, initialDuration - elapsed)
        DispatchQueue.main.async { self.timeRemaining = newRemaining }
        if newRemaining <= 0 {
            stopTimer()
        }
    }
    
    func stopTimer() {
        let studiedTime = initialDuration - timeRemaining
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        if studiedTime >= 300 {
            calculateReward()
        }
        endBackgroundTask()
    }
    
    func calculateReward() {
        let studiedTime = initialDuration - timeRemaining
        totalTimeStudied += studiedTime
        if studiedTime >= 1800 {
            reward = "🌟 Rare Planet"
        } else if studiedTime >= 900 {
            reward = "🌕 Common Planet"
        } else {
            reward = "🌑 Tiny Asteroid"
        }
        if let earnedReward = reward {
            earnedRewards.append(earnedReward)
        }
    }
    
    func harvestRewards() -> Int {
        let rewardValue = earnedRewards.reduce(0) { total, reward in
            switch reward {
            case "🌟 Rare Planet": return total + 50
            case "🌕 Common Planet": return total + 20
            case "🌑 Tiny Asteroid": return total + 5
            default: return total
            }
        }
        earnedRewards.removeAll()
        return rewardValue
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    func triggerFocusCheck() {
        isFocusCheckActive = true
    }
    
    func handleFocusAnswer(yes: Bool) {
        if yes { focusStreak += 1 } else { focusStreak = 0; stopTimer() }
        isFocusCheckActive = false
    }
    
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
