import SwiftUI
import SwiftData

@main
struct PreheatCalcApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: OvenProfile.self)
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            CalculatorView()
                .tabItem {
                    Label("Calculate", systemImage: "flame")
                }

            OvenProfileListView()
                .tabItem {
                    Label("Ovens", systemImage: "oven")
                }
        }
    }
}
