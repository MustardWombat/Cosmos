import SwiftUI

struct HomeView: View {
    @Binding var currentView: String
    @State private var path: [String] = []
    @State private var simTimer: Timer? = nil

    @EnvironmentObject var shopModel: ShopModel
    @EnvironmentObject var civModel: CivilizationModel
    @EnvironmentObject var categoriesVM: CategoriesViewModel

    var body: some View {
        ZStack {
            // 1) Black background fills the entire screen.
            Color.black
                .ignoresSafeArea()
                .zIndex(0)
            
            // 2) Starry overlay on top of the black background.
            StarOverlay(starCount: 50)
                .zIndex(1)
            
            // 3) Main content.
            NavigationStack(path: $path) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Earth image (ensure "planet01" exists in Assets).
                        Image("planet01")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .zIndex(9)
                        
                        // Weekly progress chart for the first category.
                        // If there is no category, pass a dummy UUID so the chart still appears.
                        WeeklyProgressChart(categoryID: categoriesVM.categories.first?.id ?? UUID())
                            .environmentObject(categoriesVM)
                        
                        // Population & resources info.
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Population: \(civModel.population)")
                                .foregroundColor(.white)
                            Text("Resources: \(civModel.resources)")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        
                        // Purchases section.
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
                    // Apply top, left, and right padding.
                    .padding(EdgeInsets(top: 80, leading: 20, bottom: 0, trailing: 20))
                    .frame(maxWidth: .infinity)
                }
                // Hide the default ScrollView background (iOS 16+).
                .scrollContentBackground(.hidden)
                .navigationBarBackButtonHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .zIndex(2)
        }
        .ignoresSafeArea()
        .onAppear {
            // Start simulation timer to update population/resources.
            simTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                civModel.simulate()
            }
        }
        .onDisappear {
            simTimer?.invalidate()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(currentView: .constant("Home"))
            .environmentObject(ShopModel())
            .environmentObject(CivilizationModel())
            .environmentObject(CategoriesViewModel())
    }
}
