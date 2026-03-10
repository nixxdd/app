//
//  HomeCalendarSection.swift
//  app
//
//  Created by Foundation 34 on 09/03/26.
//

import SwiftUI
import SwiftData


struct HomeCalendarSection: View {
    let monthTitle: String
    let weekDays: [Date]
    let selectedDate: Date
    let onShowCalendar: () -> Void
    let onSelectDay: (Date) -> Void
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void
    let dotColorForDay: (Date) -> Color

    private let cal = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Button(action: onPreviousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(Color.violet)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)

                Text(monthTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.violet.opacity(0.8))
                    .tracking(-0.3)

                Button(action: onNextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(Color.violet)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onShowCalendar) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .semibold))

                        Text("See all")
                            .font(.system(size: 14, weight: .heavy))
                    }
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.violet.opacity(0.8))
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                ForEach(weekDays, id: \.self) { day in
                    WeekDayPill(
                        date: day,
                        isSelected: cal.isDate(day, inSameDayAs: selectedDate),
                        dotColor: dotColorForDay(day)
                    )
                    .onTapGesture {
                        onSelectDay(day)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 6)
    }
}

