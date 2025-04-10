import SwiftUI

struct StarSpriteView: View {
    // Frame config based on your sprite sheet
    private let frameCount = 8
    private let frameSize: CGFloat = 32
    private let totalDuration: Double = 1.2
    private let startDelay: Double = Double.random(in: 0...3)

    @State private var currentFrame: Int = 0
    @State private var isVisible = false

    var body: some View {
        Image("StarSpriteSheet")
            .resizable()
            .frame(width: frameSize * CGFloat(frameCount), height: frameSize)
            .mask(
                Rectangle()
                    .frame(width: frameSize, height: frameSize)
                    .offset(x: -CGFloat(currentFrame) * frameSize)
            )
            .frame(width: frameSize, height: frameSize)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                    isVisible = true

                    Timer.scheduledTimer(withTimeInterval: totalDuration / Double(frameCount), repeats: true) { timer in
                        currentFrame += 1
                        if currentFrame >= frameCount {
                            timer.invalidate()
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isVisible = false
                            }
                        }
                    }
                }
            }
    }
}
