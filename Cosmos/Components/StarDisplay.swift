//
//  StarOverlay.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//
//  The "StarDisplay" component is responsible for the logic
//  Behind displaying coins which can be used throughout the program


import SwiftUI

struct StarOverlay: View {
    @State private var opacity: Double = 1.0
    let starCount: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<starCount, id: \.self) { _ in
                    if Double.random(in: 0...1) > 0.5 {
                        Circle()
                            .fill(Color.white)
                            .frame(width: CGFloat.random(in: 2...4),
                                   height: CGFloat.random(in: 2...4))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .opacity(Double.random(in: 0.5...opacity))
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 9.0...10.0))
                                    .repeatForever(), value: opacity
                            )
                    }
                }
            }
            .onAppear { opacity = 0.8 }
        }
        .ignoresSafeArea()
    }
}
