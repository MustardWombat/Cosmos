//
//  BottomBar.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import SwiftUI

struct BottomBarButton: View {
    let iconName: String
    let viewName: String
    @Binding var currentView: String
    
    var body: some View {
        Button(action: {
            if currentView != viewName {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
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
        .padding()                    // General padding on all sides
        .padding(.bottom, 40)         // Additional padding at the bottom
        .background(Color.gray.opacity(0.2))
    }
}
