// StreakCalculator.swift
import Foundation
import SwiftData

extension Array where Element == Medicine {
    
    func overallStreak() -> Int {
        let calendar   = Calendar.current
        let today      = Date()
        let activeMeds = self.filter { $0.isActive }
        
        guard !activeMeds.isEmpty else { return 0 }
        
        var streak       = 0
        var checkingDate = today
        
        while true {
            let allTaken = activeMeds.allSatisfy { med in
                med.wasTaken(on: checkingDate)
            }
            guard allTaken else { break }
            streak += 1
            guard let previousDay = calendar.date(
                byAdding: .day,
                value:    -1,
                to:       checkingDate
            ) else { break }
            checkingDate = previousDay
        }
        
        return streak
    }
}
