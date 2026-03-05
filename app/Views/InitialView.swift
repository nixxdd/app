//
//  ContentView.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI

struct InitialView: View {
    
    @Binding var initialized : Bool
    
    
    var body: some View {
    
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
        
            
            Button(action: {
                
                initialized = true
                
            }) {
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .foregroundColor(.cyan.opacity(0.5))
                    .frame(width:250, height: 50)
                    .shadow(radius: 10)
            }
            
        }
        .padding()
            
            
        
    }
}

#Preview {
    InitialView(initialized: .constant(false))
}
