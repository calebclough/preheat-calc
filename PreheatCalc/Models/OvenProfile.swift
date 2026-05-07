import Foundation
import SwiftData

@Model
final class OvenProfile {
    var name: String
    var preheatMinutes: Double
    var calibrationTempF: Double
    var ovenType: String

    init(name: String, preheatMinutes: Double = 10.0, calibrationTempF: Double = 425.0, ovenType: String = "Conventional") {
        self.name = name
        self.preheatMinutes = preheatMinutes
        self.calibrationTempF = calibrationTempF
        self.ovenType = ovenType
    }

    /// Heating constant k such that oven reaches ~95% of target at preheatMinutes.
    /// From: T(t) = T_room + (T_target - T_room) * (1 - e^(-kt))
    /// At t = preheatMinutes, 1 - e^(-k*t) ≈ 0.95 → k = 3.0 / preheatMinutes
    var heatingConstant: Double {
        guard preheatMinutes > 0 else { return 1.0 }
        return 3.0 / preheatMinutes
    }

    static let ovenTypes = ["Conventional", "Convection", "Toaster Oven", "Pizza Oven"]
}
