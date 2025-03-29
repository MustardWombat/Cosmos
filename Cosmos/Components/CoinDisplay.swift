//
//  CoinDisplay.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import SwiftUI

struct CoinDisplay: View {
    @EnvironmentObject var currencyModel: CurrencyModel
    
    var body: some View {
        HStack(spacing: 4) {
            Image("coin") // Ensure "coin" exists in Assets
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            Text("\(currencyModel.balance)")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
    }
}
