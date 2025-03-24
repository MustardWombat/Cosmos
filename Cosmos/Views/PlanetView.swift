//
//  PlanetView.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import SwiftUI

struct PlanetView: View {
    @Binding var currentView: String
    @EnvironmentObject var timerModel: StudyTimerModel
    @EnvironmentObject var currencyModel: CurrencyModel
    @EnvironmentObject var shopModel: ShopModel
    @EnvironmentObject var civModel: CivilizationModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Planet View")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            // Display the coin counter component
            CoinDisplay()
                .environmentObject(currencyModel)
            
            Text("Balance: \(currencyModel.balance)")
                .foregroundColor(.white)

            
            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}
