//
//  RectangleCard.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/11/21.
//

import SwiftUI

struct RectangleCard: View {
    
    var color = Color.white
    
    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}
