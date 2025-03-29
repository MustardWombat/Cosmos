import SwiftUI
import Charts

struct WeeklyProgressChart: View {
    @EnvironmentObject var viewModel: CategoriesViewModel
    let categoryID: UUID

    var body: some View {
        let logs = viewModel.weeklyData(for: categoryID)
        let category = viewModel.categories.first(where: { $0.id == categoryID })
        let pointColor = category?.displayColor ?? .blue
        
        // Determine the maximum studied minutes in the last 7 days.
        let maxMinutes = logs.map { $0.minutes }.max() ?? 0
        // The chart domain should start at 0 and go up to at least 10,
        // or the user’s maximum data if it’s above 10.
        let upperBound = max(10, maxMinutes)
        
        VStack {
            Text("Weekly Progress")
                .font(.headline)
                .padding(.bottom, 5)
            
            if #available(iOS 16.0, *) {
                if logs.isEmpty {
                    Text("No study data available")
                        .foregroundColor(.white)
                        .frame(height: 200)
                        .background(Color.black.opacity(0.7))
                } else {
                    Chart {
                        ForEach(logs) { log in
                            PointMark(
                                x: .value("Date", log.date, unit: .day),
                                y: .value("Minutes", log.minutes)
                            )
                            .symbolSize(100) // Dot size
                            .foregroundStyle(pointColor)
                        }
                    }
                    // Force the y-axis domain to start at 0 and go up to 'upperBound'.
                    .chartYScale(domain: 0...Double(upperBound))
                    
                    // Optional: reduce default chart padding
                    .chartPlotStyle { plotArea in
                        plotArea
                            .contentShape(Rectangle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                    
                    // Configure the x-axis to display days of the week
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                    .frame(height: 200)
                }
            } else {
                Text("Swift Charts is only available on iOS 16+.")
                    .foregroundColor(.gray)
                    .frame(height: 200)
            }
        }
        .padding()
    }
}
