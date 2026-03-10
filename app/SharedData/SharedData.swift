//
//  SharedData.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI
import SwiftData

struct MedIcon: Identifiable {
    var id: String { systemImage }
    let systemImage: String
    let label: String
    let color: Color

    // static lookup by systemImage name
    static let all: [MedIcon] = [
        MedIcon(systemImage: "pill.fill",       label: "Tablet",    color: .teal),
        MedIcon(systemImage: "cross.case.fill",  label: "Pack",      color: .blue),
        MedIcon(systemImage: "cross.vial.fill",  label: "Bottle",    color: .red),
        MedIcon(systemImage: "syringe.fill",     label: "Injection", color: .amber),
    ]

    static func color(for systemImage: String) -> Color {
        all.first { $0.systemImage == systemImage }?.color ?? .violet
    }
}

extension Color {
    
    static let violet = Color(red: 125/255, green:57/255, blue: 235/255)
    static let lime = Color(red: 198/255, green: 255/255, blue: 51/255)
    static let navy = Color(red:27/255, green:42/255, blue:74/255)
    static let amber = Color(red:249/255, green:192/255, blue:90/255)
    static let lightgray = Color(red:242/255, green:242/255, blue:247/255)
    
}

