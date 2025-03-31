import SwiftUI

struct PlanetView: View {
    @Binding var currentView: String
    @EnvironmentObject var miningModel: MiningModel
    @EnvironmentObject var currencyModel: CurrencyModel
    @EnvironmentObject var timerModel: StudyTimerModel
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            // Starry background overlay
            StarOverlay(starCount: 50)

            VStack(spacing: 20) {
                CoinDisplay()
                    .environmentObject(currencyModel)

                Text("Mining Bay")
                    .font(.title)
                    .foregroundColor(.white)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(miningModel.availablePlanets) { planet in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(planet.name)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Text("Reward: \(planet.miningReward)")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }

                                Spacer()

                                if miningModel.currentMiningPlanet?.id == planet.id {
                                    let minutes = miningModel.remainingTime / 60
                                    let seconds = miningModel.remainingTime % 60
                                    Text("Mining... \(String(format: "%02d:%02d", minutes, seconds))")
                                        .foregroundColor(.green)
                                } else {
                                    Button("Mine") {
                                        miningModel.startMining(planet: planet, inFocusMode: timerModel.isTimerRunning)
                                    }
                                    .disabled(miningModel.currentMiningPlanet != nil)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                        }
                    }
                }

                Spacer()
            }
            .padding(EdgeInsets(top: 80, leading: 20, bottom: 20, trailing: 20))
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            miningModel.restoreSavedMiningState()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                miningModel.refreshMiningProgress()
            }
        }
    }
}
