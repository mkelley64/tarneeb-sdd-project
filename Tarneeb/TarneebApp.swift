import SwiftUI

@main
struct TarneebApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchRootView()
        }
    }
}

// Keep animation state inside the view tree, not in App/Scene updates.
private struct LaunchRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasFinishedIntro = false
    @State private var isGameMounted = false
    @State private var introOpacity = 1.0

    var body: some View {
            ZStack {
                GameColorToken.tableBackgroundPrimary.swiftUIColor
                    .ignoresSafeArea()
                if isGameMounted {
                    ContentView()
                        .transition(.identity)
                        .zIndex(0)
                        .allowsHitTesting(hasFinishedIntro)
                        .accessibilityHidden(!hasFinishedIntro)
                }
                if !hasFinishedIntro {
                    CardFanIntro()
                        .ignoresSafeArea()
                        .opacity(introOpacity)
                        .transition(.identity)
                        // Animate a retained overlay, not simultaneous removal/insertion.
                        .zIndex(1)
                        .allowsHitTesting(false)
                }
            }
            .task(id: scenePhase) {
                guard scenePhase == .active, !hasFinishedIntro, introOpacity == 1 else { return }
                do {
                    if !isGameMounted {
                        // Do not construct the game or start its timers during the hold.
                        try await Task.sleep(for: .seconds(1))
                        try Task.checkCancellation()
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) { isGameMounted = true }
                    }
                    // Give the newly mounted table a separate layout/render interval before revealing it.
                    try await Task.sleep(for: .milliseconds(100))
                    try Task.checkCancellation()
                } catch { return }
                if reduceMotion {
                    introOpacity = 0
                    hasFinishedIntro = true
                } else {
                    withAnimation(.easeInOut(duration: 0.7), completionCriteria: .removed) {
                        introOpacity = 0
                    } completion: {
                        hasFinishedIntro = true
                    }
                }
            }
    }
}

/// Reuse the actual launch storyboard so the OS-to-app handoff has no layout jump.
private struct CardFanIntro: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIStoryboard(name: "LaunchScreen", bundle: .main)
            .instantiateInitialViewController()!
        controller.view.accessibilityIdentifier = "tarneeb-launch-intro"
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
