import SwiftUI

struct ScreenView: View {
    @EnvironmentObject var currencyModel: CurrencyModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("Screen")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity) // Full width

            VStack(alignment: .leading, spacing: 8) {
                // Top: Coin + Message
                HStack(spacing: 12) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(currencyModel.balance)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }

                // Chat message
                Text("Welcome back, Commander!")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.trailing)

                // XP Bar in the lower gap
                ProgressView(value: 0.4)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .frame(height: 6)
                    .padding(.top, 8)
                    .padding(.trailing)
            }
            .padding(.top, 16)
            .padding(.leading, 100) // Shift content past face
        }
        .frame(height: 140) // Increase size for XP bar + padding
        .padding(.horizontal)
    }
}
