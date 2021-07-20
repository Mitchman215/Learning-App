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
    @State var showResults = false
    
    var body: some View {
        
        if model.currentQuestion != nil &&
            showResults == false {
            
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
                        ForEach (0..<model.currentQuestion!.answers.count, id: \.self ) { index in
                            
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
                
                // Button to submit/advance
                Button {
                    
                    // Check if answer has been submitted
                    if submitted {
                    
                        // Check if it's the last question
                        if model.hasNextQuestion() { // is not last question
                            // move to next question
                            model.nextQuestion()
                            
                            // Reset properties
                            submitted = false
                            selectedAnswerIndex = nil
                        }
                        else { // is last question
                            showResults = true
                        }
                        
                        
                    }
                    else { // Submit the answer
                        // Change submitted state to true
                        submitted = true
                        
                        // Check answer
                        if selectedAnswerIndex == model.currentQuestion!.correctIndex {
                            numCorrect += 1
                        }
                    }
                    
                } label: {
                    ZStack {
                        RectangleCard(color: .green)
                            .frame(height: 48)
                        Text(buttonText)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                }
                .disabled(selectedAnswerIndex == nil)

            }
            .navigationTitle("\(model.currentModule?.category ?? "") Test")
        }
        else if showResults == true {
            // If currentQuestion is nil, show result view
            TestResultView(numCorrect: numCorrect)
        }
        else { // view has just been initialized
            ProgressView()
        }
        
    }
    
    // determines the text to display on the bottom submit/ advance button
    var buttonText: String {
        // if answer already submitted, button should display either
        // next question or finish depending on whether it's the final question
        if submitted {
            return model.hasNextQuestion() ? "Next Question" : "Finish"
        }
        else {
            // display submit if not submitted already
            return "Submit"
        }
    }
}
