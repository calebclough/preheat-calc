import Foundation

enum TemperatureConverter {
    static func displayString(_ tempF: Double, unit: TemperatureUnit) -> String {
        let value = unit.fromFahrenheit(tempF)
        return "\(Int(round(value)))\(unit.symbol)"
    }

    static func displayValue(_ tempF: Double, unit: TemperatureUnit) -> Int {
        Int(round(unit.fromFahrenheit(tempF)))
    }

    static func timeString(minutes: Double) -> String {
        let totalSeconds = Int(round(minutes * 60))
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        if secs == 0 {
            return "\(mins) min"
        }
        return "\(mins) min \(secs) sec"
    }
}
