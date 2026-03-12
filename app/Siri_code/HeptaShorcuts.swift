import AppIntents

struct PleaseHeptaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogMedicationIntent(),
            phrases: [
                "Confirm my medication in \(.applicationName)",
                "Track my meds in \(.applicationName)"
            ],
            shortTitle: "Log Medication",
            systemImageName: "pills.fill"
        )
    }
}

