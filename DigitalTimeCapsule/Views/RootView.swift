import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = LettersViewModel()
    @State private var selectedTab: AppTab = .home
    @State private var showingCreate = false
    @State private var path = NavigationPath()

    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        if hasOnboarded {
            mainInterface
        } else {
            OnboardingView { hasOnboarded = true }
                .transition(.opacity)
        }
    }

    private var mainInterface: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            NavigationStack(path: $path) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(viewModel: viewModel, onCreate: { showingCreate = true })
                    case .letters:
                        LettersView(viewModel: viewModel)
                    case .profile:
                        ProfileView(viewModel: viewModel)
                    case .settings:
                        SettingsView(viewModel: viewModel)
                    }
                }
                .navigationDestination(for: Letter.self) { letter in
                    LetterDetailView(viewModel: viewModel, letterID: letter.id)
                }
            }
            .tint(AppTheme.accent)

            if path.isEmpty {
                CustomTabBar(selectedTab: $selectedTab, onCreate: { showingCreate = true })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: path.isEmpty)
        .sheet(isPresented: $showingCreate) {
            CreateLetterView(viewModel: viewModel)
        }
    }
}
