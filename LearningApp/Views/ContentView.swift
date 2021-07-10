//
//  ContentView.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/9/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        
        ScrollView {
            LazyVStack (spacing: 15) {
                
                // Confirm currentModule is set
                if model.currentModule != nil {
                    
                    ForEach(0..<model.currentModule!.content.lessons.count) { index in
                        
                        let lesson = model.currentModule!.content.lessons[index]
                        
                        // Lesson card
                        ZStack (alignment: .leading) {
                            
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .frame(height: 66)
                            
                            HStack (spacing: 30) {
                                
                                Text(String(index + 1))
                                    .font(.title)
                                    .bold()
                                    .padding(.leading, 20)
                                
                                VStack (alignment: .leading) {
                                    Text(lesson.title)
                                        .bold()
                                    Text(lesson.duration)
                                }
                                
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Learn \(model.currentModule?.category ?? "")")
        }
        
    }
}
