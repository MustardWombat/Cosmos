//
//  ShopView.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import SwiftUI

struct ShopView: View {
    @Binding var currentView: String
    @EnvironmentObject var currencyModel: CurrencyModel
    @EnvironmentObject var shopModel: ShopModel
    
    @State private var items: [ShopItem] = [
        ShopItem(name: "Solar Panel", price: 30),
        ShopItem(name: "Habitat Module", price: 50),
        ShopItem(name: "Space Tractor", price: 100)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Civilization Shop")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)
                    CoinDisplay()
                        .environmentObject(currencyModel)
                    ForEach(items) { item in
                        HStack {
                            Text(item.name)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(item.price) Coins")
                                .foregroundColor(.white)
                            Button("Buy") {
                                buy(item: item)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    func buy(item: ShopItem) {
        if currencyModel.balance >= item.price {
            currencyModel.balance -= item.price
            shopModel.addPurchase(item: item)
        }
    }
}
