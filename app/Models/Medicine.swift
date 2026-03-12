//
//  Medicine.swift
//  app
//
//  Created by Foundation 34 on 06/03/26.
//

import SwiftUI
import SwiftData

@Model
class Medicine : Identifiable {
    
    var id = UUID()
    var medName : String // text field
    var dose : String // text field
    var iconName : String // icon pick
    var iconLabel : String // icon pick
    var pillCount : Int // text field
    var stockEnabled: Bool
    var stockAlertThreshold: Int
    var isActive: Bool // default true can be toggled by a slider
    var takenDates: [Date] // log of the dates the medicine tracks themselves not the user
    
    var confirmMethod: ConfirmMethod // pick
    var nfcEnabled: Bool // derived from confirmMethod
    var siriEnabled: Bool // derived from confirmMethod
    var siriPhrase: String
    var linkedTagId: UUID?
    
    var savedStreak: Int
    var lastCheckedDate: Date?
    
    @Relationship(deleteRule: .cascade) var schedule: MedSchedule?
    // if medicine removed also its schedule
    
    
    init(medName: String, dose: String, iconName: String, iconLabel: String,
         confirmMethod: ConfirmMethod, pillCount: Int,
         stockEnabled: Bool, stockAlertThreshold: Int, isActive: Bool) {
        self.medName = medName
        self.dose = dose
        self.iconName = iconName
        self.iconLabel = iconLabel
        self.confirmMethod = confirmMethod   // ← this line was missing
        self.pillCount = pillCount
        self.stockEnabled = stockEnabled
        self.stockAlertThreshold = stockAlertThreshold
        self.isActive = isActive
        self.takenDates = []
        self.savedStreak = 0
        self.lastCheckedDate = nil
        self.nfcEnabled = confirmMethod == .nfc
        self.siriEnabled = confirmMethod == .siri
        self.siriPhrase = ""
        self.linkedTagId = nil
    }
    
    
    // each medicine will compute its own streak
    func wasTaken(on date: Date) -> Bool {
        let calendar = Calendar.current // current day
        return takenDates.contains {
            takenDate in calendar.isDate(takenDate,  inSameDayAs: date)
            // we need to compare only the calendar day as Date stores data to the millisecond (cannot simply do takenDates.contains(date)
        }
    }
    
    func markAsTaken(){
        let today = Date()
        let calendar = Calendar.current
        
        // check if the medicine was taken today else exit
        guard !wasTaken(on: today) else { return }
        
        takenDates.append(today)
        
        // check if yesterday was taken
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
        print(yesterday)
        if wasTaken(on: yesterday) || savedStreak == 0 {
            savedStreak += 1
        } else {
            savedStreak = 1 // restart as the streak was broken
        }
        
        lastCheckedDate = today
        
        
    }
    
    func markAsUntaken(on date: Date = Date()) {
        takenDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    func validateStreak() {
            let calendar = Calendar.current
            let today    = Date()
            
            guard let lastChecked = lastCheckedDate else {
                // first time ever then we compute from scratch
                savedStreak = computeStreakFromHistory()
                lastCheckedDate = today
                return
            }
            
            let daysSinceCheck = calendar.dateComponents(
                [.day],
                from: lastChecked,
                to: today
            ).day ?? 0
            
            if daysSinceCheck == 0 {
                // already validated today
                return
                
            } else if daysSinceCheck == 1 {
                // one day passed then we need to check if they took it yesterday
                if !wasTaken(on: lastChecked) {
                    savedStreak = 0  // missed
                }
                
            } else {
                // multiple days missed
                savedStreak = computeStreakFromHistory()
            }
            
            lastCheckedDate = today
        }
    
    private func computeStreakFromHistory() -> Int {
            let calendar = Calendar.current
            var streak = 0
            var checkingDate = Date()
            
            while wasTaken(on: checkingDate) {
                streak += 1
                guard let previousDay = calendar.date(
                    byAdding: .day,
                    value: -1,
                    to: checkingDate
                ) else { break }
                checkingDate = previousDay
            }
            
            return streak
        }
    
}
