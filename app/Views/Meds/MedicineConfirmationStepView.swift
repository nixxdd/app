//
//  MedicineConfirmationStepView.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import SwiftUI

struct MedicineConfirmationStepView: View {
    let medicineName : String
    @Binding var confirmMethod: ConfirmMethod
    @Binding var nfcEnabled: Bool
    @Binding var siriEnabled: Bool
    @Binding var siriPhrase: String

    @FocusState private var siriFieldFocused: Bool
    
    @State private var showNFCSetup = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                VStack(spacing: 6) {
                    Text("How will you confirm?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .tracking(-0.4)
                    Text("Choose how to mark doses as taken")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 12)

                VStack(spacing: 12) {

                    // Manual — always selected, locked
                    HStack(spacing: 14) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.violet)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.violet.opacity(0.10))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("Manual")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.violet)
                                Text("· always on")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.violet.opacity(0.5))
                            }
                            Text("Tap the button in the app")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.violet)
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.violet, lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)

                    // NFC — optional toggle
                    toggleCard(
                        isOn: $nfcEnabled,
                        icon: "wave.3.right.circle.fill",
                        title: "NFC Tag",
                        description: "Tap your phone on the sticker",
                        tint: Color.violet
                    )
                
                    // Siri — optional toggle
                    toggleCard(
                        isOn: $siriEnabled,
                        icon: "mic.fill",
                        title: "Siri",
                        description: "Say the phrase to mark as taken",
                        tint: Color.violet
                    )
                }
                // Siri phrase field — only shows when siri is enabled
                if siriEnabled {
                    VStack(spacing: 0) {
                        HStack(spacing: 14) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color.violet)
                                .frame(width: 28, alignment: .center)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("You can say:")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "mic.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.violet.opacity(0.6))
                                    Text("Log my medication in PillWave")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.navy)
                                    Spacer()
                                }
                                HStack(spacing: 10) {
                                    Image(systemName: "mic.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.violet.opacity(0.6))
                                    Text("Track my meds in PillWave")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.navy)
                                    Spacer()
                                }
                                
                            }
                        }
                        .padding(16)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.2), value: siriEnabled)
                }

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        // keep confirmMethod in sync with toggles
        .onChange(of: nfcEnabled) { _, new in
            if new {
                confirmMethod = .nfc
                showNFCSetup = true
            }
            
            else if siriEnabled { confirmMethod = .siri }
            else { confirmMethod = .manual }
        }
        .onChange(of: siriEnabled) { _, new in
            if new { confirmMethod = .siri }
            else if nfcEnabled { confirmMethod = .nfc }
            else { confirmMethod = .manual }
        }
        .sheet(isPresented: $showNFCSetup) {
            NFCSetupView(medicineName: medicineName)
                .presentationDetents([.large])
        }
    }

    @ViewBuilder
    private func toggleCard(isOn: Binding<Bool>, icon: String,
                            title: String, description: String, tint: Color) -> some View {
        Button { withAnimation { isOn.wrappedValue.toggle() } } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isOn.wrappedValue ? tint : .secondary)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isOn.wrappedValue ? tint.opacity(0.10) : Color.navy.opacity(0.05))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isOn.wrappedValue ? tint : .primary)
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isOn.wrappedValue ? tint : Color.navy.opacity(0.2))
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isOn.wrappedValue ? tint : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
