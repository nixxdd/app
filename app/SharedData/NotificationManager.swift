//
//  NotificationManager.swift
//  app
//
//  Created by Foundation 34 on 09/03/26.
//
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print(granted ? "notifications allowed" : "notifications denied")
        }
    }

    // Schedule one notification per weekday the user picked
    func scheduleMedNotification(for medicine: Medicine) {
        
        // print(medicine.schedule)

        guard let schedule = medicine.schedule else { return }
        
        cancelNotification(for: medicine)

        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: schedule.time)

        let weekdays = schedule.dayWeek.isEmpty ? Array(1...7) : schedule.dayWeek.map { $0.weekdayInt }

        for weekday in weekdays {
            let content = UNMutableNotificationContent()
            content.title = "Time for \(medicine.medName) \(iconEmoji(for: medicine.iconName))"
            content.body  = "Don't forget your \(medicine.dose) dose"
            content.sound = .default
            content.categoryIdentifier = "MEDICATION_REMINDER"
            content.userInfo = ["medicineName": medicine.medName]

            // Combine weekday + hour + minute into one trigger
            var components        = DateComponents()
            components.weekday    = weekday
            components.hour       = timeComponents.hour
            components.minute     = timeComponents.minute

            let trigger = UNCalendarNotificationTrigger(
                            dateMatching: components,
                            repeats: true          
                        )

            // Unique ID: "Aspirin-3" means Aspirin on Wednesday
            let identifier = "\(medicine.medName)-\(weekday)"

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("failed to schedule \(identifier): \(error)")
                } else {
                    print("scheduled \(medicine.medName) on weekday \(weekday) at \(timeComponents.hour ?? 0):\(timeComponents.minute ?? 0)")
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.printPending()
        }
    }

    // Remove all weekday-specific notifications for this medicine
    func cancelNotification(for medicine: Medicine) {
        // Cover all 7 possible weekday identifiers
        let identifiers = (1...7).map { "\(medicine.medName)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelTodayNotification(for medicine: Medicine) {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let identifier = "\(medicine.medName)-\(weekday)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
    
    func printPending(){
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("--- Pending Notifications (\(requests.count)) ---")
                    for r in requests {
                        if let trigger = r.trigger as? UNCalendarNotificationTrigger {
                            print("ID: \(r.identifier) | weekday: \(trigger.dateComponents.weekday ?? -1) | time: \(trigger.dateComponents.hour ?? 0):\(trigger.dateComponents.minute ?? 0)")
                        } else {
                            // shows up during the 5s test
                            print("ID: \(r.identifier) | trigger: \(String(describing: r.trigger))")
                        }
                    }
                    print("-------------------------------------------")
                }
        
        
    } // end of func
}

