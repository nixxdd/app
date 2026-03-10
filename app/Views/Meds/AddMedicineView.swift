import SwiftUI
import SwiftData

struct AddMedicineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editing: Medicine? = nil

    // Navigation
    @State private var currentStep = 0
    @State private var goingForward = true

    // Identity
    @State private var medName = ""
    @State private var dose: String = ""
    @State private var selectedIcon = MedIcon(systemImage: "pill.fill", label: "Tablet", color:.teal)

    // Schedule
    @State private var time: Date = Date()
    @State private var startDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var daysOfWeek: [DayOfWeek] = []
    @State private var timesPerDay: Int = 1
    @State private var pillCount: Int = 30
    @State private var stockEnabled: Bool = false
    @State private var stockAlertThreshold: Int = 7
    @State private var isActive: Bool = true

    // Confirmation
    @State private var confirmMethod: ConfirmMethod = .manual
    @State private var nfcEnabled: Bool = false
    @State private var siriEnabled: Bool = false
    @State private var siriPhrase: String = ""
    
    @StateObject private var nfcWriter = NFCWriter()

    private var isEditing: Bool { editing != nil }

    let icons: [MedIcon] = MedIcon.all

    var body: some View {
        ZStack(alignment: .bottom) {
            
            Color.lightgray.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                ZStack {
                    switch currentStep {
                    case 0:
                        MedicineIdentityStepView(
                            medName: $medName,
                            dose: $dose,
                            selectedIcon: $selectedIcon,
                            icons: icons
                        )
                        .transition(slideTransition)

                    case 1:
                        MedicineScheduleStepView(
                            time: $time,
                            startDate: $startDate,
                            daysOfWeek: $daysOfWeek,
                            timesPerDay: $timesPerDay,
                            pillCount: $pillCount,
                            stockEnabled: $stockEnabled,
                            stockAlertThreshold: $stockAlertThreshold
                        )
                        .transition(slideTransition)

                    default:
                        MedicineConfirmationStepView(
                            medicineName : medName,
                            confirmMethod: $confirmMethod,
                            nfcEnabled: $nfcEnabled,
                            siriEnabled: $siriEnabled,
                            siriPhrase: $siriPhrase
                        )
                        .transition(slideTransition)
                    }
                }
                .animation(.easeInOut(duration: 0.28), value: currentStep)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomBar
            }
        }
        .onAppear { prefill() }
    }

    private var slideTransition: AnyTransition {
        goingForward
        ? .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal:   .move(edge: .leading).combined(with: .opacity)
          )
        : .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal:   .move(edge: .trailing).combined(with: .opacity)
          )
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack {
            Button(currentStep == 0 ? "Cancel" : "Back") {
                if currentStep == 0 { dismiss() }
                else { navigate(to: currentStep - 1) }
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(Color.violet)

            Spacer()

            Text(isEditing ? "Edit Medicine" : "New Medicine")
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            Text("Hidden").opacity(0)  // balances the title
                .font(.system(size: 16, weight: .medium))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? Color.violet : Color.navy.opacity(0.2))
                    .frame(height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
        }
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Button { handleContinue() } label: {
                Text(currentStep == 2 ? "Finish Setup" : "Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color.violet, Color.violet.opacity(0.7)],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .opacity(canContinue ? 1 : 0.45)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!canContinue)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
            .background(.ultraThinMaterial)
        }
    }

    private var canContinue: Bool {
        switch currentStep {
        case 0: return !medName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return true
        }
    }

    // MARK: - Navigation
    private func navigate(to step: Int) {
        goingForward = step > currentStep
        withAnimation { currentStep = step }
    }

    private func handleContinue() {
        if currentStep < 2 { navigate(to: currentStep + 1) }
        else { save() }
    }

    // MARK: - Prefill
    private func prefill() {
        guard let med = editing else { return }
        medName     = med.medName
        dose        = med.dose
        selectedIcon = MedIcon(systemImage: med.iconName, label: med.iconLabel, color: MedIcon.color(for: med.iconName))
        pillCount   = med.pillCount
        stockEnabled = med.stockEnabled
        stockAlertThreshold = med.stockAlertThreshold
        isActive    = med.isActive
        confirmMethod = med.confirmMethod
        nfcEnabled  = med.nfcEnabled
        siriEnabled = med.siriEnabled
        siriPhrase  = med.siriPhrase

        time        = med.schedule?.time      ?? Date()
        startDate   = med.schedule?.startDate ?? Date()
        daysOfWeek  = med.schedule?.dayWeek   ?? []
        timesPerDay = med.schedule?.timesPerDay ?? 1
    }

    // MARK: - Save
    private func save() {
        let daysToSave = daysOfWeek.contains(.all)
            ? DayOfWeek.allCases.filter { $0 != .all }
            : daysOfWeek

        if let med = editing {
            // update in place — SwiftData auto-saves
            med.medName             = medName.trimmingCharacters(in: .whitespacesAndNewlines)
            med.dose                = dose.trimmingCharacters(in: .whitespacesAndNewlines)
            med.iconName                = selectedIcon.systemImage
            med.pillCount           = pillCount
            med.stockEnabled        = stockEnabled
            med.stockAlertThreshold = stockAlertThreshold
            med.isActive            = isActive
            med.confirmMethod       = confirmMethod
            med.nfcEnabled          = nfcEnabled
            med.siriEnabled         = siriEnabled
            med.siriPhrase          = siriPhrase

            if let existing = med.schedule {
                existing.time        = time
                existing.startDate   = startDate
                existing.dayWeek     = daysToSave
                existing.timesPerDay = timesPerDay
            } else {
                let schedule = MedSchedule(time: time, startDate: startDate,
                                           dayWeek: daysToSave, timesPerDay: timesPerDay)
                med.schedule      = schedule
                schedule.medicine = med
                modelContext.insert(schedule)
            }

            NotificationManager.shared.scheduleMedNotification(for: med)

        } else {
            let newMed = Medicine(
                medName:             medName.trimmingCharacters(in: .whitespacesAndNewlines),
                dose:                dose.trimmingCharacters(in: .whitespacesAndNewlines),
                iconName:                selectedIcon.systemImage,
                iconLabel: selectedIcon.label,
                confirmMethod:       confirmMethod,
                pillCount:           pillCount,
                stockEnabled:        stockEnabled,
                stockAlertThreshold: stockAlertThreshold,
                isActive:            true
            )
            newMed.siriEnabled = siriEnabled
            newMed.siriPhrase  = siriPhrase

            let schedule = MedSchedule(time: time, startDate: startDate,
                                       dayWeek: daysToSave, timesPerDay: timesPerDay)
            newMed.schedule   = schedule
            schedule.medicine = newMed

            modelContext.insert(newMed)
            modelContext.insert(schedule)

            NotificationManager.shared.scheduleMedNotification(for: newMed)
        }
        
        if nfcEnabled {
            let nameToWrite = medName.trimmingCharacters(in: .whitespacesAndNewlines)
            // small delay so the sheet can begin dismissing first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                nfcWriter.write(text: nameToWrite)
            }
        }

        dismiss()
    }
}

#Preview {
    AddMedicineView()
        .modelContainer(for: [Medicine.self, MedSchedule.self], inMemory: true)
}
