import SwiftUI
import Charts

struct CookingChartView: View {
    let result: CookingResult
    let unit: TemperatureUnit
    let cookTempF: Double

    var body: some View {
        Chart {
            // Oven temperature curve (blue)
            ForEach(result.chartData) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Temp", unit.fromFahrenheit(point.ovenTemp))
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
            }

            // Target temperature line (red dashed)
            RuleMark(y: .value("Target", unit.fromFahrenheit(cookTempF)))
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Target \(TemperatureConverter.displayString(cookTempF, unit: unit))")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }

            // Done marker (green vertical line)
            RuleMark(x: .value("Done", result.totalMinutes))
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 2]))
                .annotation(position: .top) {
                    Text("Done!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }

            // Cooking progress area (orange)
            ForEach(result.chartData) { point in
                AreaMark(
                    x: .value("Time", point.time),
                    y: .value("Progress", point.cookingProgress * unit.fromFahrenheit(cookTempF))
                )
                .foregroundStyle(.orange.opacity(0.15))
            }
        }
        .chartXAxisLabel("Time (minutes)")
        .chartYAxisLabel("Temperature (\(unit.symbol))")
        .frame(height: 250)
    }
}
