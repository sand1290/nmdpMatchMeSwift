
import SwiftUI
import UserNotifications

@main
struct NmdpMatchMeApp: App {
    init() {
        requestNotificationPermissions()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView { LoginView() }
                    .tabItem { Label("Home", systemImage: "house") }

                NavigationView { TiktokFeedView() }
                    .tabItem { Label("Feed", systemImage: "play.rectangle") }

                NavigationView { AiChatView() }
                    .tabItem { Label("Ask AI", systemImage: "brain.head.profile") }
            }
        }
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notifications allowed")
            } else {
                print("❌ Notifications denied")
            }
        }

        UIApplication.shared.registerForRemoteNotifications()
    }
}
