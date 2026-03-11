//
//  utils.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI

public struct BackgroundedText: View {

    var color : Color = .cyan
    var text_color : Color = .white
    var size = CGSize(width: 200, height: 100)
  
    var text : String = "Hello world!"

    init(_ txt: String, _ color : Color, _ text_color : Color, _ size: CGSize) {
        self.text = txt
        self.text_color = text_color
        self.color = color
        self.size = size
    }


    public var body: some View {
        ZStack{
            Rectangle()
                .frame(width: self.size.width,
                       height: self.size.height)
                .foregroundColor(self.color)

            Text(self.text)
                .foregroundColor(self.text_color)

        }
    }
}



extension MainHomeView {
    
    var medsForSelectedDay: [Medicine] {
            medicines.filter { med in
                guard med.isActive else { return false }          // must be active
                guard let schedule = med.schedule else { return false }
                let weekday = cal.component(.weekday, from: vm.selectedDate)
                return schedule.dayWeek.contains(dayOfWeek(from: weekday))
            }
        }

    // (taken, total) tuple for the progress bar
    var progressForSelectedDay: (taken: Int, total: Int) {
        let total = medsForSelectedDay.count
        let taken = medsForSelectedDay.filter { $0.wasTaken(on: vm.selectedDate) }.count
        return (taken, total)
    }
    
    var currentAvatarMood: AvatarSentiment {
        let p = progressForSelectedDay
        if p.total == 0 { return .idle }
        if p.taken == p.total { return .happy }
        return .idle
    }
    
    var greeting: String {
        let h = cal.component(.hour, from: Date())
        if h < 12 { return "Good morning" }
        if h < 18 { return "Good afternoon" }
        return "Good evening"
    }
    
    var greetingMessage : String {
        let name = userName.isEmpty ? "Friend" : userName
        let greetingLine = "\(greeting), \(name)!"
        
        return greetingLine
        
    }
    
    var currentStreak : Int {
        medicines.overallStreak()
    }
    
    var mascotMessage : String {
        
        return "Your current streak is: \(currentStreak)"
        
    }
    
    var weekDays: [Date] {
        guard
            let currentStart = cal.date(
                from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            ),
            let start = cal.date(byAdding: .weekOfYear, value: weekOffset, to: currentStart)
        else { return [] }

        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    var currentWeekDays: [Date] {
        guard
            let start = cal.date(
                from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            )
        else { return [] }

        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        let ref = weekDays.dropFirst(3).first ?? vm.selectedDate
        return fmt.string(from: ref)
    }

    var daySectionTitle: String {
        if cal.isDateInToday(vm.selectedDate) { return "Today" }
        if cal.isDateInYesterday(vm.selectedDate) { return "Yesterday" }
        if cal.isDateInTomorrow(vm.selectedDate) { return "Tomorrow" }

        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM"
        return fmt.string(from: vm.selectedDate)
    }

    func weekDayLetter(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEEE"
        return fmt.string(from: date).uppercased()
    }

    func weekDotColor(for day: Date) -> Color {
        switch dayCompletionState(for: day) {
        case .completed:
            return Color.lime
        case .incomplete:
            return Color.indigo
        case .future, .noMeds:
            return Color.gray
        }
    }

    func changeSelectedDay(by value: Int) {
        guard let newDate = cal.date(byAdding: .day, value: value, to: vm.selectedDate) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            vm.selectedDate = newDate
            syncWeekOffsetToSelectedDate()
        }
    }

    func changeWeek(by value: Int) {
        guard let newDate = cal.date(byAdding: .weekOfYear, value: value, to: vm.selectedDate) else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            vm.selectedDate = newDate
            syncWeekOffsetToSelectedDate()
        }
    }
}

func iconEmoji(for systemImage: String) -> String {
    switch systemImage {
    case "pill.fill": return "💊"
    case "cross.case.fill":  return "🟥"
    case "cross.vial.fill":  return "🧪"
    case "syringe.fill": return "💉"
    default: return "💊"
    }
}


