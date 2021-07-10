//
//  HomeViewCard.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/9/21.
//

import SwiftUI

struct HomeViewCard: View {
    
    var image: String
    var title: String
    var description: String
    var count: String
    var time: String
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .aspectRatio(CGSize(width: 335, height: 175), contentMode: .fit)
            
            HStack {
                // Image
                Image(image)
                    .resizable()
                    .frame(width: 116, height: 116)
                    .clipShape(Circle())
                
                Spacer()
                
                // Text
                VStack(alignment: .leading, spacing: 10) {
                    // Headline
                    Text(title)
                        .bold()
                    
                    // Description
                    Text(description)
                        .padding(.bottom, 20)
                        .font(.caption)
                    
                    // Icons
                    HStack {
                        // Number of lessons/questions
                        Image(systemName: "text.book.closed")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text(count)
                            .font(Font.system(size: 10))
                        
                        Spacer()
                        
                        // Time
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text(time)
                            .font(Font.system(size: 10))
                        
                    }
                    
                }
                .padding(.leading, 20)
            }
            .padding(.horizontal, 20)
            
        }
        
    }
}

struct HomeViewCard_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewCard(image: "swift", title: "Learn Swift", description: "some description", count: "10 lessons", time: "2 hours")
    }
}
