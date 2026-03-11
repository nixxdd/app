//
//  AppDelegate.swift
//  app
//
//  Created by Foundation 34 on 09/03/26.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // MARK: - Actions
        let confirmAction = UNNotificationAction(
            identifier: "CONFIRM_MEDICATION",
            title: "✅ Mark as Taken",
            options: []
        )
        let snooze5Action = UNNotificationAction(
            identifier: "SNOOZE_5",
            title: "⏰ 5 minutes",
            options: []
        )
        let snooze10Action = UNNotificationAction(
            identifier: "SNOOZE_10",
            title: "⏰ 10 minutes",
            options: []
        )
        let snooze15Action = UNNotificationAction(
            identifier: "SNOOZE_15",
            title: "⏰ 15 minutes",
            options: []
        )
        
        // MARK: - Category
        let category = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [confirmAction, snooze5Action, snooze10Action, snooze15Action],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }
    
    // MARK: - Show banner even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // MARK: - Handle action button taps
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
            
        case "CONFIRM_MEDICATION":
            // sets the flag that MainHomeView reads on scenePhase .active
            UserDefaults.standard.set(true, forKey: "siriLogRequested")
            
        case "SNOOZE_5", "SNOOZE_10", "SNOOZE_15":
            let minutes: Double
            switch response.actionIdentifier {
            case "SNOOZE_5":  minutes = 5
            case "SNOOZE_15": minutes = 15
            default:          minutes = 10
            }
            // re-schedule the same notification after the chosen delay
            let content = response.notification.request.content.mutableCopy() as! UNMutableNotificationContent
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: minutes * 60,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Snooze scheduling failed: \(error)")
                } else {
                    print("Snoozed for \(Int(minutes)) minutes")
                }
            }
            
        default:
            break
        }
        
        completionHandler()
    }
}
