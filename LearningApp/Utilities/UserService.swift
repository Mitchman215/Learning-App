//
//  UserService.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/31/21.
//

import Foundation

class UserService {
    
    var user = User()
    
    static var shared = UserService()
    
    private init() {
        
    }
}
