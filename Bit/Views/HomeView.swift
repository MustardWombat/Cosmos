import SwiftUI
import Charts

// SpinningPlanetView shows the Earth sprite rotating continuously.
struct SpinningPlanetView: View {
    @State private var rotation: Angle = .zero

    var body: some View {
        Image("planet01")
            .resizable()
            .frame(width: 300, height: 300)
            .rotationEffect(rotation)
            .onAppear {
                withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotation = .degrees(360)
                }
            }
    }
}

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
                        XPDisplayView()
                        // Display the spinning Earth sprite.
                        SpinningPlanetView()
                        
                        WeeklyProgressChart()
                            .environmentObject(categoriesVM)
                        
                       
                        
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
            simTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                // For example, simulate passive XP gain if desired:
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
