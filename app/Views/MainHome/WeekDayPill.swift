//
//  WeekDayPill.swift
//  app
//
//  Created by Foundation 34 on 09/03/26.
//

import SwiftUI

struct WeekDayPill: View {
    let date: Date
    let isSelected: Bool
    let dotColor: Color

    private var dayLetter: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEEE"
        return fmt.string(from: date).uppercased()
    }

    private var dayNumber: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d"
        return fmt.string(from: date)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayLetter)
                .font(.system(size: 11, weight: .heavy))
                .textCase(.uppercase)
                .foregroundColor(isSelected ? .white : Color.violet)

            Text(dayNumber)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(isSelected ? .white : Color.violet.opacity(0.8))

            Circle()
                .fill(isSelected ? .white : dotColor)
                .frame(width: 8, height: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.violet.opacity(0.7) : Color.clear)
                .shadow(color: isSelected ? .black.opacity(0.3) : .clear, radius: 4)
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
