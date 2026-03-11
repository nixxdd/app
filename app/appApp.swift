//
//  appApp.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct appApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("initialized") private var initialized : Bool = false
    
    init() {
        NotificationManager.shared.requestPermission()
        PleaseHeptaShortcuts.updateAppShortcutParameters()
        
        if CommandLine.arguments.contains("-reset_arguments") {
            UserDefaults.standard.removeObject(forKey: "initialized")
        }
            
    }
    
    var body: some Scene {
        WindowGroup {
            
            if initialized {
                ContainerView()
            } else {
                InitialView()
            }
        }
        .modelContainer(for: [Medicine.self, MedSchedule.self])
    }
}
