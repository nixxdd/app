//
//  ContentView.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct InitialView: View {
    
    @AppStorage("initialized") private var initialized : Bool = false
    @State private var showNFC: Bool = false

    @AppStorage("userName") private var userName : String = ""
    
    @FocusState private var nameFieldFocused : Bool // controls wich field has focus
     
    
    var body: some View {
        
        ZStack() {
            
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
            
            
            // Circle()
            //    .fill(Color.violet.opacity(0.30))
            //    .frame(width:200)
            //    .blur(radius:80)
            //    .offset(x:150, y:400)
            
            
            VStack(alignment : .center, spacing : 12) {
                
                Text("Welcome! I'm your pill buddy")
                    .font(.system(size:30, weight: .heavy, design: .rounded))
                    .frame(width: 250, alignment: .center)
                    .multilineTextAlignment(.center)
                
                
                Text("I'll Help you keep track of your meds in a simple, smart way")
                    .font(.system(size:18, weight: .regular, design: .rounded))
                    .frame(width: 250, alignment: .center)
                    .multilineTextAlignment(.center)
                
                ZStack() {
                    
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 250, height: 300)
                        .shadow(color: Color.violet.opacity(0.25), radius: 20, y: 10)
                        .blur(radius: 10)
                    
                    AnimatedImage(name: "PillBuddy_wave.gif")
                        .resizable()
                        .scaleEffect(1.1)
                        .scaledToFit()
                        .frame(width: 350, height: 250, alignment: .center)
                        .clipShape(Circle())
                    
                } // end of ZStack For avatar and glass effect
                
                
                Text("Enter Your Name")
                    .font(.system(size:16, weight: .semibold, design: .rounded))
                    .frame(width: 280, alignment: .leading)
                
                TextField("Type", text: $userName)
                    .padding()
                    .frame(width :300, alignment: .center)
                    .background(Color(Color.violet.opacity(0.2)))
                    .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                    .shadow(color:Color.violet, radius: 10)
                    .focused($nameFieldFocused) // connects it to FocusState wants a bool condition
                    .onSubmit {
                        nameFieldFocused = false // when enter is clicked dismiss the keyboard
                    }
                
                
                Button(action: {
                    nameFieldFocused = false
                    showNFC.toggle()
                    
                }) {
                    ZStack(alignment:.center) {
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .foregroundColor(Color.lime)
                            .frame(width:160, height: 50, alignment: .center)
                            .shadow(color:Color.gray, radius: 10)
                        
                        Text("Click To Continue")
                            .font(.system(size:15, weight: .heavy, design: .rounded))
                            .foregroundColor(.navy)
                        
                        
                    } // end of ZStack
                } // end of button
                .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
            } // end of VStack
            .padding()
        }
        .onAppear { nameFieldFocused = true }
        .fullScreenCover(isPresented: $showNFC){
            InitialNFCView()
        }
    }
}

#Preview {
    InitialView()
}
