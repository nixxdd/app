//
//  appApp.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI

@main
struct appApp: App {
    
    @AppStorage("initialized") private var initialized : Bool = false
    
    init() {
        if CommandLine.arguments.contains("-reset_arguments") {
            UserDefaults.standard.removeObject(forKey: "initialized")
        }
            
    }
    
    var body: some Scene {
        WindowGroup {
            
            if initialized {
                ContainerView()
            } else {
                
                InitialView(initialized: $initialized)
            }
        }
    }
}
