import SwiftUI

struct StudyTimerView: View {
    @EnvironmentObject var timerModel: StudyTimerModel      // Timer and rewards management
    @EnvironmentObject var miningModel: MiningModel            // For mining rewards, if needed
    @EnvironmentObject var categoriesVM: CategoriesViewModel   // Manages study topics (categories)
    @Environment(\.scenePhase) var scenePhase                 // App lifecycle state

    // Track the currently selected study topic.
    @State private var selectedTopic: Category? = nil
    // Text input for creating a new study topic.
    @State private var newTopicName: String = ""

    var body: some View {
        ZStack {
            // Background: black with starry overlay.
            Color.black
                .ignoresSafeArea()
            StarOverlay(starCount: 50)
            
            VStack(spacing: 20) {
                Text("Focus Timer")
                    .font(.largeTitle)
                    .bold()
                
                // If topics exist, let the user select one.
                if !categoriesVM.categories.isEmpty {
                    Picker("Select Study Topic", selection: $selectedTopic) {
                        ForEach(categoriesVM.categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.white)
                } else {
                    Text("No topics available. Create one below.")
                        .foregroundColor(.gray)
                }
                
                // New topic creation.
                HStack {
                    TextField("Enter new topic", text: $newTopicName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        let trimmed = newTopicName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        categoriesVM.addCategory(name: trimmed, weeklyGoalMinutes: 0)
                        // Set the new topic as the selected topic.
                        selectedTopic = categoriesVM.categories.last
                        newTopicName = ""
                    }
                    .disabled(newTopicName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                
                // Timer display.
                Text(formatTime(timerModel.timeRemaining))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(timerModel.isTimerRunning ? .green : .red)
                
                // Reward display.
                if let reward = timerModel.reward {
                    Text("You earned: \(reward)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                // Control buttons.
                HStack {
                    Button(action: {
                        // Optionally, assign the selected topic to the timer model if needed.
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
                        // Log the studied minutes into the selected topic.
                        // 'studiedMinutes' should compute (initialDuration - timeRemaining) / 60.
                        if let topic = selectedTopic {
                            let minutesStudied = timerModel.studiedMinutes
                            categoriesVM.logStudyTime(categoryID: topic.id, date: Date(), minutes: minutesStudied)
                        }
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
            // Refresh the timer when the app becomes active.
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    timerModel.updateTimeRemaining()
                }
            }
            // When a reward is earned, add a new planet to the mining list.
            .onChange(of: timerModel.reward) { newReward in
                guard let reward = newReward else { return }
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
                    miningModel.availablePlanets.append(planet)
                    print("Added \(planet.name) to mining planets.")
                }
                timerModel.reward = nil
            }
        }
        .ignoresSafeArea()
    }
    
    // Utility to format time in MM:SS.
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StudyTimerView_Previews: PreviewProvider {
    static var previews: some View {
        StudyTimerView()
            .environmentObject(StudyTimerModel())
            .environmentObject(MiningModel())
            .environmentObject(CategoriesViewModel())
    }
}
