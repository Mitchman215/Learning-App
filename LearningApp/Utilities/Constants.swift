//
//  Constants.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/9/21.
//

import Foundation
import Firebase

struct Constants {
    
    static var videoHostUrl = "https://codewithchris.github.io/learningJSON/"
    
    static var firestore = Firestore.firestore()
    
    enum LoginMode {
        case login
        case createAccount
    }
}
