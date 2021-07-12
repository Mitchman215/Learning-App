//
//  TestView.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/11/21.
//

import SwiftUI

struct TestView: View {
    
    @EnvironmentObject var model: ContentModel
    @State var selectedAnswerIndex: Int?
    @State var numCorrect = 0
    @State var submitted = false
    
    var body: some View {
        
        if model.currentQuestion != nil {
            VStack (alignment: .leading){
                
                // Question number
                Text("Question \(model.currentQuestionIndex + 1) of \(model.currentModule?.test.questions.count ?? 0)")
                    .padding(.leading, 20)
                
                // Question text
                CodeTextView()
                    .padding(.horizontal, 20)
                
                // Answers
                ScrollView {
                    VStack {
                        ForEach (0..<model.currentQuestion!.answers.count) { index in
                            
                            Button {
                                // Track the selected answer index
                                selectedAnswerIndex = index
                            } label: {
                                ZStack {
                                    if !submitted {
                                        RectangleCard(color: index == selectedAnswerIndex ? .gray : .white)
                                            .frame(height: 48)
                                    }
                                    else { // Answer has been submitted
                                        // show green background for correct answer
                                        if index == model.currentQuestion!.correctIndex {
                                            RectangleCard(color: .green)
                                                .frame(height: 48)
                                        }
                                        // show red background if user selected answer isn't correct
                                        else if index == selectedAnswerIndex {
                                            RectangleCard(color: .red)
                                                .frame(height: 48)
                                        }
                                        // shows white background on all other answers
                                        else {
                                            RectangleCard()
                                                .frame(height: 48)
                                        }
                                    }
                                    
                                    Text(model.currentQuestion!.answers[index])
                                }
                            }
                            .disabled(submitted)
                        }
                    }
                    .accentColor(.black)
                    .padding()
                }
                
                // button to advance
                Button {
                    // Change submitted state to true
                    submitted = true
                    
                    // Check answer
                    if selectedAnswerIndex == model.currentQuestion!.correctIndex {
                        numCorrect += 1
                    }
                } label: {
                    ZStack {
                        RectangleCard(color: .green)
                            .frame(height: 48)
                        Text("Submit")
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                }
                .disabled(selectedAnswerIndex == nil)

            }
            .navigationTitle("\(model.currentModule?.category ?? "") Test")
        }
        
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
