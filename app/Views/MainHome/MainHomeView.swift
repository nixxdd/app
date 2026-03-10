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
    
    @StateObject private var nfcReader = NFCReader()
    
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
                                .frame(width: 370, height: 150)
                                .foregroundStyle(Color.white)
                                .shadow(color:Color.black.opacity(0.6), radius: 5)
                            
                            VStack(){
                                Text(greetingMessage)
                                    .font(.system(size: 20, weight: .heavy,design: .rounded))
                                    .foregroundColor(Color.navy)
                                    .padding(10)
                                
                                // mascot and it's phrase
                                
                                Text(mascotMessage)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.navy)
                                    .shadow(radius: 1)
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
                            onScanTapped: { nfcReader.scan() }
                        )
                        
                    } // end of the VStack inner
                    .padding(10)
                    
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
            
            .onAppear {
                
                if UserDefaults.standard.bool(forKey: "siriLogRequested") {
                    UserDefaults.standard.set(false, forKey: "siriLogRequested")
                    medsForSelectedDay
                        .filter { !$0.wasTaken(on: Date()) && $0.siriEnabled }
                        .forEach { $0.markAsTaken() }
                }
                
            }
            .onChange(of: nfcReader.lastScannedMedicineName) { _, name in
                guard let name = name else { return }
                if let match = medicines.first(where: {
                    $0.medName.lowercased() == name.lowercased() && $0.nfcEnabled
                }) {
                    match.markAsTaken()
                }
                nfcReader.lastScannedMedicineName = nil
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

#Preview {
    MainHomeView()
        .modelContainer(for: [Medicine.self, MedSchedule.self], inMemory: true)
}
