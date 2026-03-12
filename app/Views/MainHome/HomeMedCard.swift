// HomeMedCard.swift
import SwiftUI
import UIKit
import Foundation

struct HomeMedCard: View {
    let medicine: Medicine
    let date: Date

    @State private var animateButton = false

    private var isTaken: Bool {
        medicine.wasTaken(on: date)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var doseText: String {
        guard let schedule = medicine.schedule else { return "1 dose" }
        return schedule.timesPerDay == 1 ? "1 dose" : "\(schedule.timesPerDay) doses"
    }

    private var timeText: String {
        guard let schedule = medicine.schedule else { return "" }
        return schedule.time.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 16) {
            leadingIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(medicine.medName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(isTaken ? .secondary : Color.navy)

                Text(medicine.dose)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                Text(timeText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isTaken ? Color.green : Color.violet)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                isTaken
                                ? Color.green.opacity(0.12)
                                : Color.violet.opacity(0.08)
                            )
                    )
                    .padding(.top, 4)
            }

            Spacer()

            if isToday {
                takeButton
            } else {
                Image(systemName: isTaken ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isTaken ? Color.green : Color.red.opacity(0.4))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.navy.opacity(isTaken ? 0.05 : 0.2), lineWidth: 1)
        )
        .shadow(
            color:Color.navy.opacity(0.1),
            radius: 5, x:0, y:3
        )
        .animation(.easeInOut(duration: 0.28), value: isTaken)
    }

    private var leadingIcon: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    isTaken
                    ? Color.green.opacity(0.12)
                    : MedIcon.color(for: medicine.iconName).opacity(0.07)
                )
                .frame(width: 48, height: 48)

            if isTaken {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.green)
            } else {
                Image(systemName: medicine.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(MedIcon.color(for: medicine.iconName))
            }
        }
    }

    private var takeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if isTaken {
                    medicine.markAsUntaken(on: date)
                } else {
                    medicine.markAsTaken()
                }
                animateButton.toggle()
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(isTaken ? .warning : .success)
        } label: {
            HStack(spacing: 6) {
                if isTaken {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                Text(isTaken ? "Taken" : "Take")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isTaken ? .white : MedIcon.color(for: medicine.iconName))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(
                    isTaken
                    ? Color.green
                    : MedIcon.color(for: medicine.iconName).opacity(0.10)
                )
            )
            .scaleEffect(animateButton ? 1.06 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.45), value: animateButton)
        }
        .buttonStyle(.plain)
    }
}
