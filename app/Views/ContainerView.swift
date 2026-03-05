//
//  ContainerView.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI

struct ContainerView: View {
    var body: some View {
        TabView {
            
            Tab("Home", systemImage: "house.fill") {
                MainHomeView()
            }
            
            Tab("Stats", systemImage: "chart.bar.xaxis") {
                StatsView()
            }
            
        }
    }
}

#Preview {
    ContainerView()
}
