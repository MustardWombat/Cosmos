import SwiftUI

struct PlanetView: View {
    @Binding var currentView: String
    @EnvironmentObject var miningModel: MiningModel
    @EnvironmentObject var currencyModel: CurrencyModel
    @EnvironmentObject var timerModel: StudyTimerModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            // Starry background overlay (drawn above the black background).
            StarOverlay(starCount: 50)
            
            VStack(spacing: 0) {
                // Display coin counter component.
                CoinDisplay()
                    .environmentObject(currencyModel)
                
                // List available planets from MiningModel.
                ForEach(miningModel.availablePlanets) { planet in
                    HStack {
                        Text(planet.name)
                            .foregroundColor(.white)
                        Spacer()
                        Text("Reward: \(planet.miningReward)")
                            .foregroundColor(.white)
                        
                        if miningModel.currentMiningPlanet?.id == planet.id {
                            Text("Mining... \(miningModel.remainingTime)s")
                                .foregroundColor(.green)
                        } else {
                            Button("Mine") {
                                // Start mining using the current focus mode status.
                                miningModel.startMining(planet: planet, inFocusMode: timerModel.isTimerRunning)
                            }
                            .disabled(miningModel.currentMiningPlanet != nil)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                
                if miningModel.currentMiningPlanet != nil {
                    Button("Cancel Mining") {
                        miningModel.cancelMining()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(EdgeInsets(top: 80, leading: 20, bottom: 0, trailing: 20))
        }
        .ignoresSafeArea()
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                miningModel.refreshMiningProgress()
            }
        }
        .background(Color.black) // This sets the background behind the ZStack.
    }
}

struct PlanetView_Previews: PreviewProvider {
    static var previews: some View {
        PlanetView(currentView: .constant("PlanetView"))
            .environmentObject(CurrencyModel())
            .environmentObject(StudyTimerModel())
            .environmentObject(MiningModel())
    }
}
