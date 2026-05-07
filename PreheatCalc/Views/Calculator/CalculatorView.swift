import SwiftUI
import SwiftData

enum FoodStartTemp: String, CaseIterable {
    case room = "Room Temp"
    case refrigerated = "Refrigerated"
    case frozen = "Frozen"
    case custom = "Custom"

    var tempF: Double? {
        switch self {
        case .room: return 70
        case .refrigerated: return 38
        case .frozen: return 0
        case .custom: return nil
        }
    }
}

struct CalculatorView: View {
    @Query(sort: \OvenProfile.name) private var profiles: [OvenProfile]

    @State private var selectedProfile: OvenProfile?
    @State private var cookTempF: Double = 425
    @State private var cookTimeMinutes: Double = 12
    @State private var foodStartPreset: FoodStartTemp = .room
    @State private var customFoodTempF: Double = 70
    @State private var unit: TemperatureUnit = .fahrenheit
    @State private var result: CookingResult?
    @State private var showingResults = false
    @State private var resultToken = 0

    private var foodStartTempF: Double {
        foodStartPreset.tempF ?? customFoodTempF
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Form {
                    Section("Temperature Unit") {
                        Picker("Unit", selection: $unit) {
                            Text("°F").tag(TemperatureUnit.fahrenheit)
                            Text("°C").tag(TemperatureUnit.celsius)
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Oven") {
                        if profiles.isEmpty {
                            Text("No ovens configured. Go to the Ovens tab to add one.")
                                .foregroundStyle(.secondary)
                        } else {
                            Picker("Select Oven", selection: $selectedProfile) {
                                Text("Choose...").tag(nil as OvenProfile?)
                                ForEach(profiles) { profile in
                                    Text(profile.name).tag(profile as OvenProfile?)
                                }
                            }
                        }
                    }

                    Section("Cooking Settings") {
                        VStack(alignment: .leading) {
                            Text("Cook Temp: \(TemperatureConverter.displayString(cookTempF, unit: unit))")
                            Slider(value: $cookTempF, in: 200...550, step: 25)
                        }

                        VStack(alignment: .leading) {
                            Text("Package Cook Time: \(Int(cookTimeMinutes)) min")
                            Slider(value: $cookTimeMinutes, in: 1...120, step: 1)
                        }
                    }

                    Section("Food Starting Temperature") {
                        Picker("Preset", selection: $foodStartPreset) {
                            ForEach(FoodStartTemp.allCases, id: \.self) { preset in
                                Text(preset.rawValue).tag(preset)
                            }
                        }
                        .pickerStyle(.segmented)

                        if foodStartPreset == .custom {
                            VStack(alignment: .leading) {
                                Text("Food Temp: \(TemperatureConverter.displayString(customFoodTempF, unit: unit))")
                                Slider(value: $customFoodTempF, in: -10...100, step: 1)
                            }
                        } else if let tempF = foodStartPreset.tempF {
                            Text("Food starts at \(TemperatureConverter.displayString(tempF, unit: unit))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let result {
                        Section("Quick Result") {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Put food in now!")
                                        .font(.headline)
                                    Text("Done in \(TemperatureConverter.timeString(minutes: result.totalMinutes))")
                                }
                                Spacer()
                                if result.timeSavedMinutes > 0.5 {
                                    Text("\(Int(round(result.timeSavedMinutes))) min saved")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.green.opacity(0.2))
                                        .foregroundStyle(.green)
                                        .clipShape(Capsule())
                                }
                            }

                            Button("See Full Results") {
                                showingResults = true
                            }
                        }
                        .id("quickResult")
                    }
                }
                .onChange(of: resultToken) { _ in
                    withAnimation {
                        proxy.scrollTo("quickResult", anchor: .top)
                    }
                }
            }
            .navigationTitle("PreheatCalc")
            .safeAreaInset(edge: .bottom) {
                Button {
                    calculate()
                } label: {
                    Label("Calculate", systemImage: "flame")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedProfile == nil ? Color.secondary.opacity(0.3) : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedProfile == nil)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(.bar)
            }
            .sheet(isPresented: $showingResults) {
                if let result {
                    NavigationStack {
                        ResultsView(result: result, unit: unit)
                    }
                }
            }
        }
    }

    private func calculate() {
        guard let profile = selectedProfile else { return }
        result = CookingCalculator.calculate(
            profile: profile,
            cookTempF: cookTempF,
            packageCookTimeMinutes: cookTimeMinutes,
            foodStartTempF: foodStartTempF
        )
        resultToken += 1
    }
}
