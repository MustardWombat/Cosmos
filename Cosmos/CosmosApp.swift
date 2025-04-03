//
//  CosmosApp.swift
//
//
//
//
//  Created by James Williams on 3/21/25.
//

import SwiftUI

@main
struct CosmosApp: App {
    @StateObject var currencyModel = CurrencyModel()
    @StateObject var timerModel = StudyTimerModel()
    @StateObject var shopModel = ShopModel()
    @StateObject var civModel = CivilizationModel()
    @StateObject var miningModel = MiningModel()
    @StateObject var categoriesModel = CategoriesViewModel()
    @StateObject var xpModel = XPModel()  // <-- Added XPModel

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(currencyModel)
                .environmentObject(timerModel)
                .environmentObject(shopModel)
                .environmentObject(civModel)
                .environmentObject(miningModel)
                .environmentObject(categoriesModel)
                .environmentObject(xpModel)  // <-- Injected here
        }
    }
}

