//
//  SwiftUIView.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        
        ZStack () {
            RadialGradient(
                
                colors: [
                    Color.lime.opacity(0.3),
                    Color.violet.opacity(0.2),
                    Color.white
                ],
                center: .topTrailing,
                startRadius: 200,
                endRadius: 600
                
            ).ignoresSafeArea()
            
            RadialGradient(
                
                colors: [
                    Color.black.opacity(0.15),
                    Color.lime.opacity(0.3),
                    Color.violet.opacity(0.2),
                    Color.white
                ],
                center: .bottomLeading,
                startRadius: 200,
                endRadius: 600
                
            ).ignoresSafeArea()
                .blendMode(.multiply)
            
        }
        
    }
}

#Preview {
    SwiftUIView()
}
