import Foundation

enum CookingCalculator {
    static let roomTempF: Double = 70.0

    /// Oven temperature at time t (minutes) using Newton's Law of Heating.
    /// T(t) = T_room + (T_target - T_room) * (1 - e^(-kt))
    static func ovenTemp(at t: Double, targetTempF: Double, heatingConstant k: Double) -> Double {
        let tRoom = roomTempF
        return tRoom + (targetTempF - tRoom) * (1.0 - exp(-k * t))
    }

    /// Instantaneous cooking rate at time t.
    /// rate(t) = max(0, (T_oven(t) - T_food_start) / (T_target - T_food_start))
    static func cookingRate(at t: Double, targetTempF: Double, foodStartTempF: Double, heatingConstant k: Double) -> Double {
        let ovenT = ovenTemp(at: t, targetTempF: targetTempF, heatingConstant: k)
        let denominator = targetTempF - foodStartTempF
        guard denominator > 0 else { return 0 }
        return max(0, (ovenT - foodStartTempF) / denominator)
    }

    /// Accumulated cooking "equivalent minutes" from 0 to endTime using trapezoidal integration.
    static func accumulatedCooking(endTime: Double, targetTempF: Double, foodStartTempF: Double, heatingConstant k: Double, steps: Int = 500) -> Double {
        guard endTime > 0 else { return 0 }
        let dt = endTime / Double(steps)
        var integral = 0.0

        var prevRate = cookingRate(at: 0, targetTempF: targetTempF, foodStartTempF: foodStartTempF, heatingConstant: k)

        for i in 1...steps {
            let t = Double(i) * dt
            let rate = cookingRate(at: t, targetTempF: targetTempF, foodStartTempF: foodStartTempF, heatingConstant: k)
            integral += (prevRate + rate) / 2.0 * dt
            prevRate = rate
        }

        return integral
    }

    /// Find total time needed using bisection so that accumulated cooking = packageCookTime.
    static func solve(packageCookTimeMinutes: Double, targetTempF: Double, foodStartTempF: Double, heatingConstant k: Double) -> Double {
        var lo = 0.0
        var hi = packageCookTimeMinutes * 3.0 // generous upper bound

        for _ in 0..<100 {
            let mid = (lo + hi) / 2.0
            let accumulated = accumulatedCooking(endTime: mid, targetTempF: targetTempF, foodStartTempF: foodStartTempF, heatingConstant: k)
            if accumulated < packageCookTimeMinutes {
                lo = mid
            } else {
                hi = mid
            }
        }

        return (lo + hi) / 2.0
    }

    /// Full calculation returning a CookingResult with chart data.
    static func calculate(
        profile: OvenProfile,
        cookTempF: Double,
        packageCookTimeMinutes: Double,
        foodStartTempF: Double
    ) -> CookingResult {
        let k = profile.heatingConstant
        let totalTime = solve(
            packageCookTimeMinutes: packageCookTimeMinutes,
            targetTempF: cookTempF,
            foodStartTempF: foodStartTempF,
            heatingConstant: k
        )

        let conventionalTime = profile.preheatMinutes + packageCookTimeMinutes
        let timeSaved = conventionalTime - totalTime

        // Generate chart data points
        let pointCount = 100
        let maxTime = max(totalTime, conventionalTime) * 1.1
        var chartPoints: [CookingResult.ChartPoint] = []

        for i in 0...pointCount {
            let t = maxTime * Double(i) / Double(pointCount)
            let temp = ovenTemp(at: t, targetTempF: cookTempF, heatingConstant: k)
            let accumulated = accumulatedCooking(endTime: t, targetTempF: cookTempF, foodStartTempF: foodStartTempF, heatingConstant: k)
            let progress = min(1.0, accumulated / packageCookTimeMinutes)
            chartPoints.append(.init(time: t, ovenTemp: temp, cookingProgress: progress))
        }

        return CookingResult(
            totalMinutes: totalTime,
            timeSavedMinutes: max(0, timeSaved),
            conventionalMinutes: conventionalTime,
            cookTempF: cookTempF,
            chartData: chartPoints
        )
    }
}
