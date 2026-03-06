//
//  Enums.swift
//  app
//
//  Created by Foundation 34 on 06/03/26.
//

import Foundation
import SwiftUI

enum ConfirmMethod : String, Codable, CaseIterable {
    case backBotton = "backBotton"
    case nfc = "nfc"
}

enum AvatarSentiment {
    
    case idle
    case happy
    case mad
    
}

enum DayOfWeek: String, Codable, CaseIterable {
    case monday    = "Monday"
    case tuesday   = "Tuesday"
    case wednesday = "Wednesday"
    case thursday  = "Thursday"
    case friday    = "Friday"
    case saturday  = "Saturday"
    case sunday    = "Sunday"
    case all = "All Days"
}

enum StreakState {
    case valid
    case broken // needs reset
    case unknown // when app is opened check
}



