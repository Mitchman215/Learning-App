//
//  LearningAppApp.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/7/21.
//

import SwiftUI

@main
struct LearningApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(ContentModel())
        }
    }
}
