import SwiftUI

struct HomeView: View {
    @Binding var currentView: String
    @State private var path: [String] = []
    @State private var simTimer: Timer? = nil

    @EnvironmentObject var shopModel: ShopModel
    @EnvironmentObject var categoriesVM: CategoriesViewModel
    @EnvironmentObject var xpModel: XPModel

    var body: some View {
        ZStack {
            // 1) Black background fills the entire screen.
            Color.black
                .ignoresSafeArea()
                .zIndex(0)
                .overlay(Text("")) // Spacer overlay if needed
            
            // 2) Starry overlay on top of the black background.
            StarOverlay(starCount: 50)
                .zIndex(999)
            
            // 3) Main content.
            NavigationStack(path: $path) {
                ScrollView {
                    VStack(spacing: 20) {
                        Image("planet01")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .zIndex(9)
                        
                        WeeklyProgressChart()
                            .environmentObject(categoriesVM)
                        
                        // XP / Level system replaces population and resources.
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Level: \(xpModel.level)")
                                .foregroundColor(.white)
                            ProgressView(value: Double(xpModel.xp), total: Double(xpModel.xpForNextLevel))
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            Text("\(xpModel.xp) / \(xpModel.xpForNextLevel) XP")
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
                    .padding(EdgeInsets(top: 80, leading: 20, bottom: 0, trailing: 20))
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                }
                .scrollContentBackground(.hidden)
                .navigationBarBackButtonHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .zIndex(2)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .onAppear {
            // You might simulate XP gain here if desired.
            simTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                // For example, simulate passive XP gain:
                // xpModel.addXP(10)
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
            .environmentObject(CategoriesViewModel())
            .environmentObject(XPModel())
    }
}
