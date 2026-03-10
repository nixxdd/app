//
//  MedicineScheduleStepView.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import SwiftUI

struct MedicineScheduleStepView: View {
    @Binding var time: Date
    @Binding var startDate: Date
    @Binding var daysOfWeek: [DayOfWeek]
    @Binding var timesPerDay: Int
    @Binding var pillCount: Int
    @Binding var stockEnabled: Bool
    @Binding var stockAlertThreshold: Int

    private let allDays = DayOfWeek.allCases

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                VStack(spacing: 6) {
                    Text("Set the schedule")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .tracking(-0.4)
                    Text("When should we remind you?")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 12)

                // Time + Start Date
                VStack(spacing: 0) {
                    rowView(label: "Time") {
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    Divider().padding(.leading, 16)
                    rowView(label: "Start Date") {
                        DatePicker("", selection: $startDate,
                                   in: Date()...,
                                   displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    Divider().padding(.leading, 16)
                    rowView(label: "Times per day") {
                        Stepper("\(timesPerDay)", value: $timesPerDay, in: 1...10)
                            .labelsHidden()
                        Text("\(timesPerDay)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.violet)
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)

                // Day picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Days Of The Week")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        ForEach(allDays, id: \.self) { day in
                            let isSelected: Bool = {
                                if day == .all {
                                    let real = DayOfWeek.allCases.filter { $0 != .all }
                                    return real.allSatisfy { daysOfWeek.contains($0) }
                                }
                                return daysOfWeek.contains(day)
                            }()

                            Text(day == .all ? "ALL" : day.rawValue.prefix(2).uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(isSelected ? .white : Color.violet)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(
                                    isSelected ? Color.violet : Color.violet.opacity(0.10)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    if day == .all {
                                        let real = DayOfWeek.allCases.filter { $0 != .all }
                                        daysOfWeek = real.allSatisfy { daysOfWeek.contains($0) }
                                            ? [] : real
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
                }

                // Stock tracking
                VStack(spacing: 0) {
                    rowView(label: "Track stock") {
                        Toggle("", isOn: $stockEnabled)
                            .tint(Color.violet)
                            .labelsHidden()
                    }

                    if stockEnabled {
                        Divider().padding(.leading, 16)
                        rowView(label: "Pill count") {
                            Stepper("", value: $pillCount, in: 1...500, step: 5)
                                .labelsHidden()
                            Text("\(pillCount)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.violet)
                        }
                        Divider().padding(.leading, 16)
                        rowView(label: "Alert when below") {
                            Stepper("", value: $stockAlertThreshold, in: 1...30)
                                .labelsHidden()
                            Text("\(stockAlertThreshold)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.2), value: stockEnabled)

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private func rowView<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
            Spacer()
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
