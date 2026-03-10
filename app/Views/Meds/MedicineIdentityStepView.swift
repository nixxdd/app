//
//  MedicineIdentityStepView.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import SwiftUI

struct MedicineIdentityStepView: View {
    @Binding var medName: String
    @Binding var dose: String
    @Binding var selectedIcon: MedIcon
    let icons: [MedIcon]

    @FocusState private var nameFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {

                VStack(spacing: 6) {
                    Text("What's the medicine?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .tracking(-0.4)
                    Text("Pick an icon and fill in the details")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 12)

                // Icon picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("ICON")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 10) {
                        ForEach(icons) { icon in
                            iconCell(icon)
                        }
                    }
                }

                // Name + Dose fields
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        Image(systemName: selectedIcon.systemImage)
                            .font(.system(size: 20))
                            .foregroundColor(selectedIcon.color)
                            .frame(width: 28, alignment: .center)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Name")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            TextField("e.g. Aspirin", text: $medName)
                                .font(.system(size: 16))
                                .focused($nameFocused)
                        }
                    }
                    .padding(16)

                    Divider().padding(.leading, 56)

                    HStack(spacing: 14) {
                        Image(systemName: "scalemass")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .frame(width: 28, alignment: .center)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dosage (optional)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            TextField("e.g. 500mg", text: $dose)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(16)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear { nameFocused = true }
    }

    @ViewBuilder
    private func iconCell(_ icon: MedIcon) -> some View {
        let isSelected = selectedIcon.systemImage == icon.systemImage
        VStack(spacing: 6) {
            Image(systemName: icon.systemImage)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? icon.color : .secondary)
                .frame(width: 52, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? icon.color.opacity(0.10) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? icon.color : Color.clear, lineWidth: 1.5)
                )
            Text(icon.label)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? icon.color : .secondary)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) { selectedIcon = icon }
        }
    }
}
