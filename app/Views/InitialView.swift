//
//  ContentView.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI

struct InitialView: View {
    var body: some View {
        NavigationStack() {
            
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello")
            }
            .padding()
            
            
        } // end of NavigationStack
    }
}

#Preview {
    InitialView()
}
