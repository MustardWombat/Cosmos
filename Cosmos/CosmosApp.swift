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
    // Store shared models using @StateObject for persistence
    @StateObject var currencyModel = CurrencyModel()
    @StateObject var timerModel = StudyTimerModel()
    @StateObject var shopModel = ShopModel()
    @StateObject var civModel = CivilizationModel()
    @StateObject var miningModel = MiningModel()
    @StateObject var categoriesModel = CategoriesViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject environment objects for use in all views:
                .environmentObject(currencyModel)
                .environmentObject(timerModel)
                .environmentObject(shopModel)
                .environmentObject(civModel)
                .environmentObject(miningModel)
                .environmentObject(categoriesModel)
        }
    }
}
