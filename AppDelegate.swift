//
//  AppDelegate.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Steven Anderson on 2025-06-15.
//

import UIKit

class AppDelegate: NSObject, ObservableObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @Published var notificationCount = 0
    @Published var matchAlertIsPresented = false
    @Published var kitReceivedAlertIsPresented = false
    @Published var hlaResultsIsPresented = false
    @Published var deviceTokenString = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("✅ Notifications allowed by user and registered")
            } else {
                print("❌ Notifications denied: \(String(describing: error))")
            }
        }
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
        print("Device push notification token - \(deviceTokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notification. Error \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        notificationCount += 1
        if notification.request.content.categoryIdentifier == "KIT_RECEIVED" {
            kitReceivedAlertIsPresented = true
        }
        else if notification.request.content.categoryIdentifier == "TYPING_COMPLETE" {
            hlaResultsIsPresented = true
        }
        else if notification.request.content.categoryIdentifier == "MATCH_RESULT" {
            matchAlertIsPresented = true
        }
        completion([.banner, .sound, .badge])
    }
}
