//
//  ContentViewCard.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/9/21.
//

import SwiftUI

struct ContentViewCard: View {
    
    @EnvironmentObject var model: ContentModel
    var index: Int
    
    var lesson: Lesson {
        if model.currentModule != nil && index < model.currentModule!.content.lessons.count {
            return model.currentModule!.content.lessons[index]
        }
        else {
            return Lesson(id: 0, title: "", video: "", duration: "", explanation: "")
        }
    }
    
    var body: some View {
        
        // Lesson card
        ZStack (alignment: .leading) {
            
            RectangleCard()
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
