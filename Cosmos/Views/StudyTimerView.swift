import SwiftUI

struct StudyTimerView: View {
    @EnvironmentObject var timerModel: StudyTimerModel
    @EnvironmentObject var miningModel: MiningModel
    @EnvironmentObject var categoriesVM: CategoriesViewModel
    @Environment(\.scenePhase) var scenePhase

    @State private var selectedTopic: Category? = nil {
        didSet {
            categoriesVM.saveSelectedTopicID(selectedTopic?.id)
        }
    }

    @State private var newTopicName: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            StarOverlay(starCount: 50)

            VStack(spacing: 20) {
                Text("Focus Timer")
                    .font(.largeTitle)
                    .bold()

                // MARK: - Topic Selector List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select a Study Topic:")
                        .font(.headline)
                        .foregroundColor(.white)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(categoriesVM.categories) { category in
                                Button(action: {
                                    selectedTopic = category
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(category.displayColor)
                                            .frame(width: 12, height: 12)

                                        Text(category.name)
                                            .foregroundColor(.white)
                                            .padding(.leading, 5)

                                        Spacer()

                                        if selectedTopic?.id == category.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedTopic?.id == category.id ? Color.green : Color.gray, lineWidth: 2)
                                    )
                                }
                            }

                            // Add new topic inline
                            HStack {
                                TextField("New Topic", text: $newTopicName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Add") {
                                    let trimmed = newTopicName.trimmingCharacters(in: .whitespaces)
                                    guard !trimmed.isEmpty else { return }
                                    categoriesVM.addCategory(name: trimmed)
                                    selectedTopic = categoriesVM.categories.last
                                    newTopicName = ""
                                }
                                .disabled(newTopicName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                            .padding(.top)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                }

                // MARK: - Timer display
                Text(formatTime(timerModel.timeRemaining))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(timerModel.isTimerRunning ? .green : .red)

                // MARK: - Reward display
                if let reward = timerModel.reward {
                    Text("You earned: \(reward)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }

                // MARK: - Control buttons
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
                        if let topic = selectedTopic {
                            let minutesStudied = timerModel.studiedMinutes
                            categoriesVM.logStudyTime(categoryID: topic.id, date: Date(), minutes: minutesStudied)
                        }
                        timerModel.stopTimer()
                        
                        // If a reward was earned, add a planet based on that reward.
                        if let reward = timerModel.reward {
                            miningModel.addPlanet(for: reward)
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
            .onAppear {
                if selectedTopic == nil {
                    selectedTopic = categoriesVM.loadSelectedTopic()
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    timerModel.updateTimeRemaining()
                }
            }
            .onChange(of: timerModel.reward) { newReward in
                guard let reward = newReward else { return }
                var newPlanet: Planet?
                switch reward {
                case "Rare Planet":
                    newPlanet = Planet(name: "Rare Planet", baseMiningTime: 120, miningReward: 50)
                case "Common Planet":
                    newPlanet = Planet(name: "Common Planet", baseMiningTime: 90, miningReward: 20)
                case "Tiny Asteroid":
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
    }

    // Utility to format time in MM:SS
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StudyTimerView_Previews: PreviewProvider {
    static var previews: some View {
        StudyTimerView()
            .environmentObject(StudyTimerModel(xpModel: XPModel()))
            .environmentObject(MiningModel())
            .environmentObject(CategoriesViewModel())
    }
}
