//
//  HomeView.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentView: String
    @State private var path: [String] = []
    @State private var simTimer: Timer? = nil
    
    @EnvironmentObject var shopModel: ShopModel
    @EnvironmentObject var civModel: CivilizationModel
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Display the Earth image from Assets (ensure asset name "planet01" exists)
                        Image("planet01")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Population: \(civModel.population)")
                                .foregroundColor(.white)
                            Text("Resources: \(civModel.resources)")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Purchases")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.orange)
                            if shopModel.purchasedItems.isEmpty {
                                Text("No items purchased yet.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(shopModel.purchasedItems) { item in
                                    HStack {
                                        Text(item.name)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("Qty: \(item.quantity)")
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            simTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                civModel.simulate()
            }
        }
        .onDisappear {
            simTimer?.invalidate()
        }
    }
}
