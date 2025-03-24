//
//  StudyTimerView.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import SwiftUI

struct StudyTimerView: View {
    @EnvironmentObject var timerModel: StudyTimerModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Focus Timer")
                .font(.largeTitle)
                .bold()
            Text(formatTime(timerModel.timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .foregroundColor(timerModel.isTimerRunning ? .green : .red)
            if let reward = timerModel.reward {
                Text("You earned: \(reward)")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            HStack {
                Button(action: {
                    timerModel.startTimer(for: 25 * 60)
                }) {
                    Text("Add 25 Min")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    timerModel.stopTimer()
                }) {
                    Text("Land")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!timerModel.isTimerRunning)
            }
            .padding()
            Spacer()
        }
        .padding()
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                timerModel.updateTimeRemaining()
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
