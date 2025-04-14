import SwiftUI

struct BottomBarButton: View {
    let iconName: String
    let viewName: String
    @Binding var currentView: String

    var body: some View {
        Button(action: {
            if currentView != viewName {
                #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                #endif
                currentView = viewName
            }
        }) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(currentView == viewName ? Color.orange : Color.white)
                .brightness(currentView == viewName ? 0.3 : 0)
        }
    }
}

struct LayoutShell: View {
    @Binding var currentView: String
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            // 🔼 Top bar
            ZStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 8) {
                    // Coin and balance
                    HStack(spacing: 6) {
                        CoinDisplay()
                            .font(.subheadline.monospaced())
                            .foregroundColor(Color(red: 0.0, green: 1, blue: 0.0))
                    }

                    // Welcome text
                    Text("Welcome back, Commander!")
                        .font(.subheadline.monospaced())
                        .foregroundColor(Color(red: 0.0, green: 1, blue: 0.0))

                    Spacer()
                }
                .padding(.top, 40)
                .padding(.leading, 115)
                .frame(height: 140)
                .background(Color.clear)
            }
            .padding(.top, -25)

            // 🧩 Main content area
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 🔽 Bottom bar
            BottomBar(currentView: $currentView)
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.black) // <-- Set black background for the entire layout
    }
}

struct BottomBar: View {
    @Binding var currentView: String

    var body: some View {
        HStack {
            Spacer()
            BottomBarButton(iconName: "house.fill", viewName: "Home", currentView: $currentView)
            Spacer()
            BottomBarButton(iconName: "globe", viewName: "PlanetView", currentView: $currentView)
            Spacer()
            BottomBarButton(iconName: "gearshape.fill", viewName: "StudySession", currentView: $currentView)
            Spacer()
            BottomBarButton(iconName: "cart.fill", viewName: "Shop", currentView: $currentView)
            Spacer()
        }
        .padding()
        .padding(.bottom, 40)
        .background(Color.clear)
    }
}
