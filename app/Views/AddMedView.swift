//
//  AddMedView.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI
import SwiftData

struct AddMedView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // initializing the variables we need to fill from medicine
    
    @State private var medName : String = ""
    @State private var dose : String = ""
    @State private var pillCount: Int = 0
    @State private var confirmMethod: ConfirmMethod = .backBotton
    @State private var isActive: Bool = true

    @State private var selectedIcon: MedIcon = MedIcon(
            systemImage: "pill.fill",
            label: "Tablet"
        )
    
    let icons: [MedIcon] = [
            MedIcon(systemImage: "pill.fill", label: "Tablet"),
            MedIcon(systemImage: "cross.case.fill", label: "Pack"),
            MedIcon(systemImage: "cross.vial.fill", label: "Bottle"),
            MedIcon(systemImage: "syringe.fill", label: "Injection"),
        ]
    
    var isValid : Bool {
        !medName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dose.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @FocusState private var nameFieldFocused : Bool // controls wich field has focus
    
    @State var scheduleView : Bool = false
    
    @State var time : Date = Date()
    @State var startDate : Date = Date()
    @State var daysOfWeek : [DayOfWeek] = []
    @State var timesPerDay : Int = 1
    
    var body: some View {
        NavigationStack() {
            ZStack{
                
                Color.cyan.opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture {
                        nameFieldFocused = false
                    }
                
                VStack(alignment: .center) {
                    
                    
                    Text("Name Of Medicine")
                        .font(.headline)
                    
                    TextField("Type", text: $medName)
                        .padding()
                        .frame(width :300, alignment: .center)
                        .background(Color(.cyan.opacity(0.4)))
                        .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                        .focused($nameFieldFocused) // connects it to FocusState wants a bool condition
                        .onSubmit {
                            nameFieldFocused = false // when enter is clicked dismiss the keyboard
                        }
                    
                    Text("Pick Icon")
                        .font(.system(size: 15, weight: .semibold))
                    
                    HStack(alignment: .center) {
                        ForEach(icons) {
                            icon in
                            VStack() {
                                Image(systemName: icon.systemImage)
                                    .font(.title2)
                                Text(icon.label)
                                    .font(.caption2)
                            } // end of Loop VStack
                            .padding(10)
                            .background(
                                icon.id == selectedIcon.id
                                ? Color.cyan.opacity(0.3)
                                : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(12)
                            .onTapGesture {
                                selectedIcon = icon
                                
                            }
                        } // end of for loop
                    } // end of HStack
                    
                    HStack() {
                        
                        Text("Dose:")
                            .font(.headline)
                        
                        TextField("Type", text: $dose)
                            .padding()
                            .frame(width :200, alignment: .center)
                            .background(Color(.cyan.opacity(0.4)))
                            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                            .focused($nameFieldFocused) // connects it to FocusState wants a bool condition
                            .onSubmit {
                                nameFieldFocused = false // when enter is clicked dismiss the keyboard
                            }
                        
                        
                        
                    }
                    Button(action: {scheduleView.toggle()}) {
                        Text("Schedule")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50)
                            .background(isValid ? Color.cyan : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                    }
                    
                    
                    Button(action: saveMedicine) {
                        Text("Add Medicine")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(isValid ? Color.cyan : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                    }
                    .disabled(!isValid)
                    
                } // end of VStack
                .padding(40)
                
                
            } // end of ZStack
        }
        .sheet(isPresented: $scheduleView) {
            ScheduleView(
                time : $time,
                startDate : $startDate,
                daysOfWeek : $daysOfWeek,
                timesPerDay : $timesPerDay
            )
        }
    }
    func saveMedicine() {
        print("save medicine clicked")
        
        let daysToSave = daysOfWeek.contains(.all)
            ? DayOfWeek.allCases.filter { $0 != .all }
            : daysOfWeek

        let newMed = Medicine(
            medName : medName,
            dose : dose,
            iconName: selectedIcon.systemImage,
            iconLabel: selectedIcon.label,
            confirmMethod: ConfirmMethod.backBotton,
            pillCount: 30,
            isActive: true
        )
        
        let schedule = MedSchedule(
            time:        time,
            startDate:   startDate,
            dayWeek:     daysToSave,
            timesPerDay: timesPerDay
        )
        
        modelContext.insert(newMed)
        modelContext.insert(schedule)
        
        newMed.schedule = schedule
        schedule.medicine = newMed
        
        dismiss()
    }
}

#Preview {
    AddMedView()
        .modelContainer(for: Medicine.self, inMemory: true)
}
