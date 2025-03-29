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
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject environment objects for use in all views:
                .environmentObject(CurrencyModel())
                .environmentObject(StudyTimerModel())
                .environmentObject(ShopModel())
                .environmentObject(CivilizationModel())
                .environmentObject(MiningModel())
                .environmentObject(CategoriesViewModel())

        }
    }
}
