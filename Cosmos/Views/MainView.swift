//
//  MainView.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import SwiftUI

struct MainView: View {
    @State private var currentView: String = "Home"
    
    var body: some View {
        VStack(spacing: 0) {
            // The main content area uses a switch to display the selected view.
            Group {
                switch currentView {
                case "Home":
                    HomeView(currentView: $currentView)
                case "PlanetView":
                    PlanetView(currentView: $currentView)
                case "StudySession":
                    SessionView(currentView: $currentView)
                case "Shop":
                    ShopView(currentView: $currentView)
                default:
                    HomeView(currentView: $currentView)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // The bottom bar remains fixed.
            BottomBar(currentView: $currentView)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
