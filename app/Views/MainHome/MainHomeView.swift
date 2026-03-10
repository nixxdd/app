//
//  MainHomeView.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct MainHomeView: View {
    
    // @EnvironmentObject var vm: AppViewModel
    @AppStorage("userName") var userName = ""
    @AppStorage("initialized") var initialized: Bool = true
    
    // Getting the Data
    @Query var medicines : [Medicine]
    
    
    let cal = Calendar.current
    @State var weekOffset: Int = 0
    @State var showCalendar: Bool = false
    @State var vm: HomeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack () {
            
            ZStack {
                
                
                Color.gray.opacity(0.07)
                    .ignoresSafeArea()
                
                
                ScrollView {
                    
                    VStack(alignment: .center, spacing: 40) {
                        
                        ZStack(alignment: .leading) {
                            
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .frame(width: 365, height: 150)
                                .foregroundStyle(Color.white)
                                .shadow(color:Color.black.opacity(0.6), radius: 5)
                            
                            VStack(){
                                Text(greetingMessage)
                                    .font(.system(size: 20, weight: .heavy,design: .rounded))
                                    .padding(10)
                                
                                // mascot and it's phrase
                                
                                Text(mascotMessage)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .shadow(radius: 1)
                                    .foregroundColor(Color.black)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .foregroundStyle(Color.violet.opacity(0.3))
                                            .shadow(color:Color.black.opacity(0.3), radius: 5)
                                    )
                                    .offset(x:20)
                                
                            } // end of VStack for the card
                            
                            AnimatedImage(name:"PillBuddy_wave.gif")
                                .resizable()
                                .frame(width: 180, height: 150)
                                .scaleEffect(0.9)
                                .offset(x:230)
                            
                        } // end of ZStack for greeting
                    
                        
                        HomeCalendarSection(
                            monthTitle:    monthTitle,
                            weekDays:      weekDays,
                            selectedDate:  vm.selectedDate,
                            onShowCalendar: { showCalendar = true },
                            onSelectDay:   { day in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    vm.selectedDate = day
                                }
                            },
                            onPreviousWeek: { changeWeek(by: -1) },
                            onNextWeek:     { changeWeek(by: 1) },
                            dotColorForDay: { day in weekDotColor(for: day) }
                        )
                        
                        HomeMedsSection(
                            daySectionTitle: daySectionTitle,
                            progress: progressForSelectedDay,
                            activeMeds: medsForSelectedDay,
                            pilbyMood: currentAvatarMood,
                            date: vm.selectedDate,
                            onScanTapped: { }
                        )
                        
                    } // end of the VStack inner
                    
                } // end of the scroll view
                
            } // end of ZStack
            .sheet(isPresented: $showCalendar) {
                        // full calendar picker sheet
                        DatePicker(
                            "Select Date",
                            selection: $vm.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        .presentationDetents([.medium])  // half screen sheet
                    }
            
        } // end of NavigationStack
        
    }
    
    func syncWeekOffsetToSelectedDate() {
        let currentWeekStart = cal.date(
            from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()
        let selectedWeekStart = cal.date(
            from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: vm.selectedDate)
        ) ?? Date()
        let diff = cal.dateComponents([.weekOfYear], from: currentWeekStart, to: selectedWeekStart)
        weekOffset = diff.weekOfYear ?? 0
    }
    
    // checks how many medicines were taken on a given day
    func dayCompletionState(for day: Date) -> DayCompletionState {
        let activeMeds = medicines.filter { $0.isActive }
        guard !activeMeds.isEmpty else { return .noMeds }
        
        // future days
        if day > Date() && !cal.isDateInToday(day) { return .future }
        
        let takenCount = activeMeds.filter { $0.wasTaken(on: day) }.count
        
        if takenCount == 0           { return .incomplete }
        if takenCount == activeMeds.count { return .completed }
        return .incomplete
    }
    
    // converts iOS weekday integer to your DayOfWeek enum
    func dayOfWeek(from weekday: Int) -> DayOfWeek {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

struct MedDayRowView: View {
    
    let medicine: Medicine
    let date: Date
    
    var isTaken: Bool { medicine.wasTaken(on: date) }
    var isToday: Bool { Calendar.current.isDateInToday(date) }
    
    var body: some View {
        HStack(spacing: 14) {
            
            // icon
            Image(systemName: medicine.iconName)
                .font(.title3)
                .foregroundColor(Color.violet)
                .frame(width: 44, height: 44)
                .background(Color.violet.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // name + time
            VStack(alignment: .leading, spacing: 2) {
                Text(medicine.medName)
                    .font(.system(size: 15, weight: .bold))
                if let schedule = medicine.schedule {
                    Text(schedule.time.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // taken indicator / button
            if isToday {
                Button(action: {
                    medicine.markAsTaken()
                }) {
                    Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundColor(isTaken ? Color.lime : Color.gray.opacity(0.4))
                }
                .buttonStyle(.plain)
            } else {
                // past days — just show status, no button
                Image(systemName: isTaken ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isTaken ? Color.lime : Color.red.opacity(0.4))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
    }
}

#Preview {
    MainHomeView()
        .modelContainer(for: [Medicine.self, MedSchedule.self], inMemory: true)
}
