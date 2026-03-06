//
//  ScheduleView.swift
//  app
//
//  Created by Foundation 34 on 06/03/26.
//

import SwiftUI

struct ScheduleView: View {
    
    @Binding var time : Date
    @Binding var startDate : Date
    @Binding var daysOfWeek : [DayOfWeek]
    @Binding var timesPerDay : Int
    
    @Environment(\.dismiss) private var dismiss
    
    let allDays : [DayOfWeek] = DayOfWeek.allCases
    
    var body: some View {
        
        NavigationStack{
            
            ZStack {
                Color.indigo.opacity(0.1)
                .ignoresSafeArea()
                
                VStack(alignment: .center) {
                    
                    HStack(alignment:.center){
                        
                        Text("Start Date:")
                            .font(.system(size:20, weight: .semibold))
                        
                        DatePicker(
                            "Start Date",
                            selection: $startDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        
                    }
                    
                    HStack(alignment:.center){
                        
                        Text("Time:")
                            .font(.system(size:20, weight: .semibold))
                        
                        DatePicker(
                            "time",
                            selection: $time,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        
                    }
                    
                    VStack(alignment:.center){
                        
                        Text("Days Of Week:")
                            .font(.system(size:20, weight: .semibold))
                        
                        HStack {
                            ForEach(allDays, id: \.self) { day in
                                
                                let isSelected: Bool = {
                                    if day == .all {
                                        let realDays = DayOfWeek.allCases.filter { $0 != .all }
                                        return realDays.allSatisfy { daysOfWeek.contains($0) }
                                    } else {
                                        return daysOfWeek.contains(day)
                                    }
                                }()
                                
                                // show "AL" for all, first 2 letters for real days
                                Text(day == .all ? "AL" : day.rawValue.prefix(2).uppercased())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(isSelected ? .white : .indigo)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        isSelected
                                            ? Color.indigo
                                            : Color.indigo.opacity(0.15)
                                    )
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        if day == .all {
                                            let realDays = DayOfWeek.allCases.filter { $0 != .all }
                                            if realDays.allSatisfy({ daysOfWeek.contains($0) }) {
                                                daysOfWeek = []
                                            } else {
                                                daysOfWeek = realDays
                                            }
                                        } else {
                                            if daysOfWeek.contains(day) {
                                                daysOfWeek.removeAll { $0 == day }
                                            } else {
                                                daysOfWeek.append(day)
                                            }
                                        }
                                    }
                            }
                        }
                        
                        Stepper("Times per day: \(timesPerDay)", value: $timesPerDay, in: 1...10)
                                                .font(.system(size: 18, weight: .semibold))
                        
                        Button(action: { dismiss() }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color.indigo)
                                .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                            }
                        
                        } // end of VStack

                }
                .padding(30)
                
            }
            
        } // end of Navigation Stack
    } // end of View
}

#Preview {
    // wrapper gives us real @State to test with
    struct PreviewWrapper: View {
        @State var time        = Date()
        @State var startDate   = Date()
        @State var daysOfWeek: [DayOfWeek] = []
        @State var timesPerDay = 1
        
        var body: some View {
            ScheduleView(
                time:        $time,
                startDate:   $startDate,
                daysOfWeek:  $daysOfWeek,
                timesPerDay: $timesPerDay
            )
        }
    }
    return PreviewWrapper()
}
