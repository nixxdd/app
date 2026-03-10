//
//  NotificationManager.swift
//  app
//
//  Created by Foundation 34 on 09/03/26.
//

// NotificationManager.swift
import UserNotifications

class NotificationManager {
    
    // shared singleton — access it anywhere with NotificationManager.shared
    static let shared = NotificationManager()
    
    // ask the user for permission to send notifications
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("notifications allowed")
            } else {
                print("notifications denied")
            }
        }
    }
    
    // schedule a daily notification for a medicine
    func scheduleMedNotification(for medicine: Medicine) {
        guard let schedule = medicine.schedule else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for \(medicine.medName) \(iconEmoji(for: medicine.iconName))"
        content.body  = "Don't forget your \(medicine.dose) dose"
        content.sound = .default
        
        // extract hour and minute from schedule.time
        let components = Calendar.current.dateComponents([.hour, .minute], from: schedule.time)
        
        // trigger fires every day at this time
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: medicine.medName, // unique ID per medicine
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("failed to schedule: \(error)")
            } else {
                print("scheduled notification for \(medicine.medName)")
            }
        }
    }
    
    // cancel notifications for a specific medicine
    func cancelNotification(for medicine: Medicine) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [medicine.medName]
        )
    }
    
    // cancel ALL notifications — useful for testing
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}


