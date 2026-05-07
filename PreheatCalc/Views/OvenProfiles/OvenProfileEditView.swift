import SwiftUI
import SwiftData

struct OvenProfileEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let profile: OvenProfile?

    @State private var name: String = ""
    @State private var preheatMinutes: Double = 10.0
    @State private var calibrationTempF: Double = 425.0
    @State private var ovenType: String = "Conventional"

    private var isNew: Bool { profile == nil }

    var body: some View {
        Form {
            Section("Oven Details") {
                TextField("Name", text: $name)

                Picker("Type", selection: $ovenType) {
                    ForEach(OvenProfile.ovenTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
            }

            Section("Preheat Settings") {
                VStack(alignment: .leading) {
                    Text("Preheat Time: \(Int(preheatMinutes)) min")
                    Slider(value: $preheatMinutes, in: 1...30, step: 1)
                }

                VStack(alignment: .leading) {
                    Text("Calibration Temp: \(Int(calibrationTempF))°F")
                    Slider(value: $calibrationTempF, in: 200...550, step: 25)
                }
            }

            Section {
                Text("Preheat time is how long your oven takes to reach the calibration temperature. Check your oven manual or time it yourself.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(isNew ? "New Oven" : "Edit Oven")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isNew ? "Add" : "Save") {
                    save()
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            if let profile {
                name = profile.name
                preheatMinutes = profile.preheatMinutes
                calibrationTempF = profile.calibrationTempF
                ovenType = profile.ovenType
            }
        }
    }

    private func save() {
        if let profile {
            profile.name = name
            profile.preheatMinutes = preheatMinutes
            profile.calibrationTempF = calibrationTempF
            profile.ovenType = ovenType
        } else {
            let newProfile = OvenProfile(
                name: name,
                preheatMinutes: preheatMinutes,
                calibrationTempF: calibrationTempF,
                ovenType: ovenType
            )
            modelContext.insert(newProfile)
        }
    }
}
