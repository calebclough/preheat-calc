import Foundation

struct CookingResult {
    let totalMinutes: Double
    let timeSavedMinutes: Double
    let conventionalMinutes: Double
    let cookTempF: Double
    let chartData: [ChartPoint]

    struct ChartPoint: Identifiable {
        let id = UUID()
        let time: Double          // minutes
        let ovenTemp: Double      // °F
        let cookingProgress: Double // 0.0 to 1.0
    }
}
