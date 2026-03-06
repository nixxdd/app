    //
    //  MedSchedule.swift
    //  app
    //
    //  Created by Foundation 34 on 06/03/26.
    //

    import SwiftUI
    import SwiftData

    @Model
    class MedSchedule {
        
        var time : Date
        var startDate : Date
        var dayWeek : [DayOfWeek]
        var timesPerDay : Int
        
        var medicine : Medicine? // back reference to medicine
        
        init(time: Date, startDate : Date, dayWeek: [DayOfWeek], timesPerDay: Int) {
            self.time = time
            self.startDate = startDate
            self.dayWeek = dayWeek
            self.timesPerDay = timesPerDay
        }
        
        
    }

