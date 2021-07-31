//
//  LoginView.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/29/21.
//

import SwiftUI
import Firebase


struct LoginView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var loginMode = Constants.LoginMode.login
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    private var buttonText: String {
        if loginMode == Constants.LoginMode.login {
            return "Login"
        }
        else {
            return "Create Account"
        }
    }
    
    var body: some View {
        VStack (spacing: 10) {
            
            Spacer()
            
            // Logo
            Image("CSEBRI-Logo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 150)
            
            // Title
            Text("Learn with Cultural Society")
            
            Spacer()
            
            // Picker
            Picker(selection: $loginMode, label: Text("Base")) {
                Text("Login")
                    .tag(Constants.LoginMode.login)
                Text("Create Account")
                    .tag(Constants.LoginMode.createAccount)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Form
            Group {
                TextField("Email", text: $email)
                    
                
                if loginMode == Constants.LoginMode.createAccount {
                    TextField("Name", text: $name)
                }
                
                SecureField("Password", text: $password)
                
                if errorMessage != nil {
                    Text(errorMessage!)
                        .foregroundColor(.red)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Button
            Button {
                if loginMode == Constants.LoginMode.login {
                    // Log the user in
                    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                        
                        // Check for errors
                        guard error == nil else {
                            self.errorMessage = error!.localizedDescription
                            return
                        }
                        // Clear error message
                        self.errorMessage = nil
                        
                        // Fetch user meta data
                        model.getUserData()
                        
                        // Check if user is logged in and if so,
                        // change the view to logged in view
                        model.checkLogin()
                        
                    }
                }
                else {
                    // Create a new account
                    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        
                        // Check for errors
                        guard error == nil else {
                            self.errorMessage = error!.localizedDescription
                            return
                        }
                        // Clear error message
                        
                        // Save the first name
                        let firebaseUser = Auth.auth().currentUser
                        let db = Firestore.firestore()
                        let ref = db.collection("users").document(firebaseUser!.uid)
                        
                        ref.setData(["name":name], merge: true)
                        
                        // Update the user meta data
                        let user = UserService.shared.user
                        user.name = name
                        
                        // Check if user is logged in and if so,
                        // change the view to logged in view
                        model.checkLogin()
                        
                        
                    }
                }
            } label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(height: 40)
                        .cornerRadius(10)
                    
                    Text(buttonText)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()

        }
        .padding(.horizontal, 40)
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
