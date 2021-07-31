//
//  ProfileView.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/29/21.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        Button {
            // sign out the user
            try! Auth.auth().signOut()
            
            // Change to logged out view
            model.checkLogin()
            
        } label: {
            Text("Sign out")
        }

    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
