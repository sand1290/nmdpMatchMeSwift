
import SwiftUI
import UserNotifications

@main
struct NmdpMatchMeApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
