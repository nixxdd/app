//
//  SharedData.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI
import SwiftData

struct MedIcon : Identifiable {
    
    let id = UUID()
    let systemImage : String
    let label : String
    
}

extension Color {
    
    static let violet = Color(red: 125/255, green:57/255, blue: 235/255)
    static let lime = Color(red: 198/255, green: 255/255, blue: 51/255)
    
}

