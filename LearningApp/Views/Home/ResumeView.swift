//
//  ResumeView.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/31/21.
//

import SwiftUI

struct ResumeView: View {
    
    @EnvironmentObject var model: ContentModel
    @State var resumeSelected: Int?
    
    let user = UserService.shared.user
    
    private var resumeTitle: String {
        
        if let lastLesson = user.lastLesson,
           let lastModule = user.lastModule,
           let lastQuestion = user.lastQuestion {
            
            let module = model.modules[lastModule]
            
            if lastLesson != 0 {
                // Resume a lesson
                return "Learn \(module.category): Lesson \(lastLesson + 1)"
            }
            else {
                // Resume a test
                return "\(module.category) Test: Question \(lastQuestion + 1)"
            }
        }
        else {
            // Should never reach here
            return ""
        }
    }
    
    var destination: some View {
        
        let module = model.modules[user.lastModule ?? 0]
        
        return Group {
            // Determine if we need to go into a ContentDetailView or a TestView
            if user.lastLesson! > 0 {
                // Go to ContentDetailView
                ContentDetailView()
                    .onAppear(perform: {
                        // Fetch lessons
                        model.getLessons(module: module) {
                            model.beginModule(module.id)
                            model.beginLesson(user.lastLesson!)
                        }
                    })
            }
            else {
                // Go to TestView
                TestView()
                    .onAppear(perform: {
                        model.getQuestions(module: module) {
                            model.beginTest(module.id)
                            model.currentQuestionIndex = user.lastQuestion!
                        }
                    })
            }
        }
    }
    
    var body: some View {
        
        let module = model.modules[user.lastModule ?? 0]
        
        NavigationLink(destination: destination,
                       tag: module.id.hash,
                       selection: $resumeSelected) {
            ZStack {
                RectangleCard(color: .white)
                    .frame(height: 66)
                
                HStack {
                    VStack (alignment: .leading) {
                        Text("Continue where you left off:")
                        Text(resumeTitle)
                            .bold()
                    }
                    
                    Spacer()
                    
                    Image("play")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .scaledToFit()
                }
                .padding()
                .foregroundColor(.black)
            }
        }
    }
}

struct ResumeView_Previews: PreviewProvider {
    static var previews: some View {
        ResumeView()
    }
}
