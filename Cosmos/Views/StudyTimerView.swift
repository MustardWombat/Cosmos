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

    @State private var isShowingCategorySheet = false
    @State private var showSessionEndedPopup = false


    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            StarOverlay(starCount: 50)

            VStack(spacing: 20) {
                Text("Focus Timer")
                    .font(.largeTitle)
                    .bold()

                // MARK: - Topic Selector Sheet Trigger
                VStack(alignment: .leading, spacing: 10) {
                    Text("Selected Topic:")
                        .font(.headline)
                        .foregroundColor(.white)

                    Button(action: {
                        isShowingCategorySheet = true
                    }) {
                        HStack {
                            if let topic = selectedTopic {
                                Circle()
                                    .fill(topic.displayColor)
                                    .frame(width: 12, height: 12)
                                Text(topic.name)
                                    .foregroundColor(.white)
                            } else {
                                Text("Choose a topic")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.up")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                    }
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
                // ✅ No longer constructing planets here
                // Planet creation is handled inside StudyTimerModel via miningModel.getPlanet(ofType:)

                // Just clear the reward after showing it
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    timerModel.reward = nil
                }
            }
            .onChange(of: timerModel.timeRemaining) { newValue in
                if newValue == 0 && !timerModel.isTimerRunning {
                    showSessionEndedPopup = true
                }
            }

            .sheet(isPresented: $isShowingCategorySheet) {
                CategorySelectionSheet(
                    categories: categoriesVM.categories,
                    selected: $selectedTopic,
                    isPresented: $isShowingCategorySheet,
                    onAddCategory: { name in
                        categoriesVM.addCategory(name: name)
                        selectedTopic = categoriesVM.categories.last
                    },
                    onDeleteCategory: { category in
                        categoriesVM.deleteCategory(category)
                        if selectedTopic?.id == category.id {
                            selectedTopic = nil
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showSessionEndedPopup) {
            VStack(spacing: 20) {
                Text("⏰ Time's Up!")
                    .font(.largeTitle)
                    .bold()
                Text("You studied for \(timerModel.studiedMinutes) minutes.")
                    .multilineTextAlignment(.center)
                Button("Awesome!") {
                    showSessionEndedPopup = false
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }

    }

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
