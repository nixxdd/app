//
//  Enums.swift
//  app
//
//  Created by Foundation 34 on 06/03/26.
//

import Foundation
import SwiftUI

enum ConfirmMethod : String, Codable, CaseIterable {
    case siri = "siri"
    case nfc = "nfc"
    case manual = "manual"
}

enum AvatarSentiment {
    
    case idle
    case happy
    case sad
    
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
extension DayOfWeek {
    var weekdayInt: Int {
        switch self {
        case .sunday:    return 1
        case .monday:    return 2
        case .tuesday:   return 3
        case .wednesday: return 4
        case .thursday:  return 5
        case .friday:    return 6
        case .saturday:  return 7
        case .all:       return -1
        }
    }
}

enum StreakState {
    case valid
    case broken
    case unknown
}

enum DayCompletionState {
    case completed
    case incomplete
    case future
    case noMeds
}





