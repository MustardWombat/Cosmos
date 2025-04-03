import SwiftUI

struct CosmosAppView: View {
    @StateObject var xpModel: XPModel
    @StateObject var timerModel: StudyTimerModel
    @StateObject var shopModel = ShopModel()
    @StateObject var civModel = CivilizationModel()
    @StateObject var miningModel = MiningModel()
    @StateObject var categoriesModel = CategoriesViewModel()
    @StateObject var currencyModel = CurrencyModel()


    init() {
        let xp = XPModel()
        _xpModel = StateObject(wrappedValue: xp)
        _timerModel = StateObject(wrappedValue: StudyTimerModel(xpModel: xp))
    }
    
    var body: some View {
        ContentView()
            .environmentObject(xpModel)
            .environmentObject(timerModel)
            .environmentObject(shopModel)
            .environmentObject(civModel)
            .environmentObject(miningModel)
            .environmentObject(categoriesModel)
            .environmentObject(currencyModel)

    }
}

@main
struct CosmosApp: App {
    var body: some Scene {
        WindowGroup {
            CosmosAppView()
        }
    }
}
