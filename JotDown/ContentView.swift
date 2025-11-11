import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query var users: [User]

    @State private var selectedTab = 0
    @Namespace private var ns
    @State private var categoryToPresent: Category? = nil
    @State private var dashboardResetID = UUID()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack {
                    HomeView(selectedTab: $selectedTab, categoryToPresent: $categoryToPresent)
                        .onAppear {
                            if users.isEmpty {
                                let defaultUser = User(name: "", bio: "")
                                context.insert(defaultUser)
                            }
                        }
                }
            } label: {
                Image("Visualize")
                    .renderingMode(.template)
            }

            Tab(value: 1) {
                NavigationStack {
                    DashboardView()
                }
                .id(dashboardResetID)
            } label: {
                Image("Dashboard")
                    .renderingMode(.template)
            }

            Tab(value: 2) {
                NavigationStack {
                    ProfileView()
                }
            } label: {
                Image("User")
                    .renderingMode(.template)
            }

            Tab(value: 3) {
                NavigationStack {
                    VisualizationView()
                }
            } label: {
                Image(.dashboard)
                    .renderingMode(.template)
            }

            Tab(value: 4, role: .search) {
                NavigationStack {
                    CombinedSearchView()
                }
            } label: {
                Image("Search")
                    .renderingMode(.template)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue == 1 && newValue != 1 {
                dashboardResetID = UUID()
                categoryToPresent = nil
            }
        }
        .fullScreenCover(item: $categoryToPresent) { show in
            CategoryDashboardView(
                category: show,
                namespace: ns,
                onDismiss: { categoryToPresent = nil }
            )
        }
        // to change tab icon color onSelected add:
        // .tint(.gray)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
