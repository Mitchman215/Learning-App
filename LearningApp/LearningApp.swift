//
//  LearningAppApp.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/7/21.
//

import SwiftUI
import Firebase

@main
struct LearningApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(ContentModel())
        }
    }
}
