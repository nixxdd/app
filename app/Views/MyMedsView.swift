//
//  MyMedsView.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI
import SwiftData

struct MyMedsView: View {
        
    @State var addMed : Bool = false
    
    @Query var medicines : [Medicine]
    
    var body: some View {
        NavigationStack() {
            
            ZStack () {
                
                Color.cyan.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack() {
                    
                    Text("My Meds")
                    
                    Button(action: {
                        addMed.toggle()
                        }) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .foregroundColor(.cyan.opacity(0.5))
                                .frame(width:250, height: 50)
                                .shadow(radius: 10)

                            Text("+ Add Med")
                                .foregroundColor(.white)
                                .font(.system(size:15, weight: .bold))

                        }
                    }
                    ForEach(medicines) { medicine in
                        VStack(alignment: .leading) {
                            Text(medicine.medName)
                                .font(.headline)
                            Text("Streak: \(medicine.savedStreak)")
                            if let schedule = medicine.schedule {
                                Text(schedule.time.formatted(date: .omitted, time: .shortened))
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    
                } // end of VStack
                .navigationTitle("My Meds")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { addMed.toggle() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Add Med")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                
            }
        }
        .sheet(isPresented: $addMed) {
            AddMedView()
        
        }
        
    }
}



#Preview {
    MyMedsView()
}
