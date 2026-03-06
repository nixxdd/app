//
//  EditMedView.swift
//  app
//
//  Created by Foundation 34 on 06/03/26.
//

import SwiftUI
import SwiftData

struct EditMedView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let medicine : Medicine

    @State private var medName: String
    @State private var dose: String
    @State private var pillCount: Int
    @State private var isActive: Bool
    @State private var selectedIcon: MedIcon
    
    @State private var time: Date
    @State private var startDate: Date
    @State private var daysOfWeek: [DayOfWeek]
    @State private var timesPerDay: Int
    
    @State private var scheduleView: Bool = false
    @FocusState private var focused: Bool
    
    let icons: [MedIcon] = [
        MedIcon(systemImage: "pill.fill", label: "Tablet"),
        MedIcon(systemImage: "cross.case.fill", label: "Pack"),
        MedIcon(systemImage: "cross.vial.fill", label: "Bottle"),
        MedIcon(systemImage: "syringe.fill", label: "Injection"),
    ]
    
    init(medicine: Medicine) {
        self.medicine = medicine
        
        // _varName to set a @State initial value outside the init
        _medName = State(initialValue: medicine.medName)
        _dose = State(initialValue: medicine.dose)
        _pillCount = State(initialValue: medicine.pillCount)
        _isActive = State(initialValue: medicine.isActive)
        _selectedIcon = State(initialValue:
            MedIcon(systemImage: medicine.iconName, label: medicine.iconLabel)
        )
        
        // pre-fill schedule if it exists, otherwise use defaults
        _time        = State(initialValue: medicine.schedule?.time        ?? Date())
        _startDate   = State(initialValue: medicine.schedule?.startDate   ?? Date())
        _daysOfWeek  = State(initialValue: medicine.schedule?.dayWeek     ?? [])
        _timesPerDay = State(initialValue: medicine.schedule?.timesPerDay ?? 1)
    }
        
    var isValid: Bool {
        !medName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dose.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        
        NavigationStack() {
            
            ZStack(){
                
                // background
                Color.cyan.opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture { focused = false }
                
                VStack(){
                    
                    TextField("Medicine name", text: $medName)
                        .padding()
                        .frame(width: 300)
                        .background(Color.cyan.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                        .focused($focused)
                    
                    HStack() {
                        ForEach(icons) { icon in
                            VStack(spacing: 4) {
                                Image(systemName: icon.systemImage)
                                    .font(.title2)
                                Text(icon.label)
                                    .font(.caption2)
                            }
                            .padding(10)
                            .background(
                                icon.systemImage == selectedIcon.systemImage
                                ? Color.cyan.opacity(0.3)
                                : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(12)
                            .onTapGesture { selectedIcon = icon }
                        }
                    } // end of HStack for icon
                    
                    HStack() {
                        
                        Text("Dose:")
                            .font(.headline)
                        
                        TextField("e.g. 500mg", text: $dose)
                            .padding()
                            .frame(width: 200)
                            .background(Color.cyan.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                            .focused($focused)
                            .onSubmit {
                                focused = false // when enter is clicked dismiss the keyboard
                            }
                        
                    } // end of HStack for dose
                    
                    Button(action: {scheduleView.toggle()}) {
                        Text("Edit Schedule")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 160, height: 50)
                            .background(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                    } // end of button for editing schedule
                    
                    Button(action : saveChanges) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(isValid ? Color.cyan : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                    } // end of botton for saving changes
                    .disabled(!isValid)
                     
                } // end of VStack
                .padding(100)
                .sheet(isPresented : $scheduleView) {
                    ScheduleView(
                        time:        $time,
                        startDate:   $startDate,
                        daysOfWeek:  $daysOfWeek,
                        timesPerDay: $timesPerDay
                    )
                }
            }
            
        } // end of navigationStack
    }
    
    func saveChanges() {
        medicine.medName   = medName
        medicine.dose = dose
        medicine.pillCount = pillCount
        medicine.isActive = isActive
        medicine.iconName = selectedIcon.systemImage
        medicine.iconLabel = selectedIcon.label
        
        let daysToSave = daysOfWeek.contains(.all)
            ? DayOfWeek.allCases.filter { $0 != .all }
            : daysOfWeek
        
        if let existing = medicine.schedule {
            // update existing schedule in place
            existing.time        = time
            existing.startDate   = startDate
            existing.dayWeek     = daysToSave
            existing.timesPerDay = timesPerDay
        } else {
            // create new schedule if none existed
            let schedule = MedSchedule(
                time:        time,
                startDate:   startDate,
                dayWeek:     daysToSave,
                timesPerDay: timesPerDay
            )
            medicine.schedule    = schedule
            schedule.medicine    = medicine
            modelContext.insert(schedule)
        }
        
        dismiss()
        
    } // end of function declaration
    
}

#Preview {
    // create a sample medicine to preview with
    let config  = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    
    let sample = Medicine(
        medName:       "Vitamin D",
        dose:          "500mg",
        iconName:      "pill.fill",
        iconLabel:     "Tablet",
        confirmMethod: .backBotton,
        pillCount:     30,
        isActive:      true
    )
    container.mainContext.insert(sample)
    
    return EditMedView(medicine: sample)
        .modelContainer(container)
}
