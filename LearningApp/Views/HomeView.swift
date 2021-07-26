//
//  ContentView.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/7/21.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model:ContentModel
    
    var body: some View {
        
        NavigationView {
            VStack (alignment: .leading) {
                
                Text("What do you want to do today?")
                    .padding(.leading, 20)
                
                ScrollView {
                    LazyVStack {
                        ForEach (model.modules) { module in
                            VStack (spacing: 20) {
                                
                                NavigationLink(
                                    destination: ContentView()
                                                    .onAppear(perform: {
                                                            model.beginModule(module.id)
                                                        }),
                                    tag: module.id.hash,
                                    selection: $model.currentContentSelected) {
                                        // MARK: Learning Card
                                        HomeViewCard(image: module.content.image,
                                                     title: "Learn \(module.category)",
                                                     description: module.content.description,
                                                     count: "\(module.content.lessons.count) Lessons",
                                                     time: module.content.time)
                                    }
                                
                                NavigationLink(
                                    destination: TestView()
                                                    .onAppear(perform: {
                                                        model.beginTest(module.id)
                                                    }),
                                    tag: module.id.hash,
                                    selection: $model.currentTestSelected) {
                                    
                                    // MARK: Test Card
                                    HomeViewCard(image: module.test.image,
                                                 title: "\(module.category) Test",
                                                 description: module.test.description,
                                                 count: "\(module.test.questions.count) Lessons",
                                                 time: module.test.time)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .accentColor(.black)
                    .padding()
                }
            }
            .navigationTitle("Get Started")
            .onChange(of: model.currentContentSelected) { (changedValue) in
                if changedValue == nil {
                    model.currentModule = nil
                }
            }
            .onChange(of: model.currentTestSelected) { changedValue in
                if changedValue == nil {
                    model.currentModule = nil
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ContentModel())
    }
}
