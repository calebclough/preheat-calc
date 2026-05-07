import SwiftUI
import SwiftData

struct OvenProfileListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OvenProfile.name) private var profiles: [OvenProfile]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                if profiles.isEmpty {
                    ContentUnavailableView(
                        "No Ovens",
                        systemImage: "oven",
                        description: Text("Add your oven to get started.")
                    )
                }

                ForEach(profiles) { profile in
                    NavigationLink {
                        OvenProfileEditView(profile: profile)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name)
                                .font(.headline)
                            HStack {
                                Text(profile.ovenType)
                                Text("·")
                                Text("Preheat: \(Int(profile.preheatMinutes)) min")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteProfiles)
            }
            .navigationTitle("My Ovens")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    OvenProfileEditView(profile: nil)
                }
            }
        }
    }

    private func deleteProfiles(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(profiles[index])
        }
    }
}
