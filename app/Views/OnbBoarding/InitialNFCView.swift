//
//  InitialNFCView.swift
//  app
//
//  Created by Foundation 34 on 06/03/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct InitialNFCView: View {
    
    @AppStorage("initialized") private var initialized: Bool = false
    
    // @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack(){
            
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
            
            
            VStack (alignment : .center, spacing : 12) {
                Text("Confirm your dose with a tap")
                    .font(.system(size:30, weight: .heavy))
                    .frame(width: 250, alignment: .center)
                    .multilineTextAlignment(.center)
                
                Text("Just bring your phone close to the NFC tag on your pill bottle")
                    .font(.system(size:18, weight: .regular))
                    .frame(width: 250, alignment: .center)
                    .multilineTextAlignment(.center)
                
                ZStack() {
                    
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 250, height: 300)
                        .shadow(color: Color.violet.opacity(0.25), radius: 20, y: 10)
                        .blur(radius: 10)
                    
                    AnimatedImage(name: "pillBuddy_NFC.gif") // pill with the NFC
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 280, alignment: .center)
                        .clipShape(Circle())
                    
                } // end of ZStack
                
                
                Button(action: {
                    initialized = true
                }) {
                    
                    ZStack(){
                        
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .foregroundColor(Color.violet.opacity(0.5))
                            .frame(width:150, height: 50, alignment: .center)
                            .shadow(color:Color.gray, radius: 10)
                        
                        Text("Get Started")
                            .font(.system(size:12, weight: .heavy))
                            .foregroundColor(.white)
                        
                    } // end of ZStack of the botton
                    
                }
            } // end of VStack
            .padding()

            
        } // end of ZStack for background
    }
}

#Preview {
    InitialNFCView()
}
