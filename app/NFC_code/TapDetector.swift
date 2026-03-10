//
//  TapDetector.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//


import Foundation
import CoreMotion
import Combine
import UIKit
import UserNotifications // 1. Import the notifications framework

class TapDetector: ObservableObject {

    private let motionManager = CMMotionManager()
    var onTapDetected: (() -> Void)? = nil

    @Published var tapCount: Int = UserDefaults.standard.integer(forKey: "tapCount")

    // MARK: Sensitivity
    private let tapThreshold: Double = 3.0

    // cooldown
    private var lastTapTime: Date = Date()
    private let cooldownInterval: TimeInterval = 1.0

    init() {
        requestNotificationPermission() // 2. Request permission when initialized
        startMonitoring()

        // Restart when app returns from background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Notification Setup
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func sendLocalNotification(timeString: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time to take your medicine! 💊"
        content.body = "Tap to log it at \(timeString)"
        content.sound = .default

        // Trigger immediately (0.1 seconds is the minimum interval allowed)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Create a unique request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Add to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Motion Monitoring
    func startMonitoring() {

        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }

        if motionManager.isAccelerometerActive {
            return
        }

        motionManager.accelerometerUpdateInterval = 0.02

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in

            guard let self = self else { return }
            guard let acceleration = data?.acceleration else { return }

            let totalAcceleration = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            )

            if totalAcceleration > self.tapThreshold {

                let now = Date()

                if now.timeIntervalSince(self.lastTapTime) > self.cooldownInterval {

                    self.lastTapTime = now
                    self.handlePhysicalTrigger()
                }
            }
        }
    }

    private func handlePhysicalTrigger() {

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()

        tapCount += 1

        // Save permanently
        UserDefaults.standard.set(tapCount, forKey: "tapCount")

        // Showing Time
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: now)
        
        print("Hard Shake Detected! Total: \(tapCount)" + " --- " + timeString)
        
        
        sendLocalNotification(timeString: timeString)
        
        DispatchQueue.main.async {
            self.onTapDetected?()
        }
    }

    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
    }

    @objc private func appDidBecomeActive() {
        startMonitoring()
    }
}
