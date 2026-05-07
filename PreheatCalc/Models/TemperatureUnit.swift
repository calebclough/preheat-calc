import Foundation

enum TemperatureUnit: String, CaseIterable, Codable {
    case fahrenheit = "F"
    case celsius = "C"

    var symbol: String {
        switch self {
        case .fahrenheit: return "°F"
        case .celsius: return "°C"
        }
    }

    static func toFahrenheit(_ celsius: Double) -> Double {
        celsius * 9.0 / 5.0 + 32.0
    }

    static func toCelsius(_ fahrenheit: Double) -> Double {
        (fahrenheit - 32.0) * 5.0 / 9.0
    }

    func toFahrenheit(_ value: Double) -> Double {
        switch self {
        case .fahrenheit: return value
        case .celsius: return TemperatureUnit.toFahrenheit(value)
        }
    }

    func fromFahrenheit(_ fahrenheit: Double) -> Double {
        switch self {
        case .fahrenheit: return fahrenheit
        case .celsius: return TemperatureUnit.toCelsius(fahrenheit)
        }
    }
}
