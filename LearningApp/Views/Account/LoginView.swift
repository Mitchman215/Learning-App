//
//  LoginView.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/29/21.
//

import SwiftUI


struct LoginView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var loginMode = Constants.LoginMode.login
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    
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
            TextField("Email", text: $email)
                
            
            if loginMode == Constants.LoginMode.createAccount {
                TextField("Name", text: $name)
            }
            
            SecureField("Password", text: $password)
            
            // Button
            Button {
                if loginMode == Constants.LoginMode.login {
                    // Log the user in
                }
                else {
                    // Create a new account
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
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
