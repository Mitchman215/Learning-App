//
//  ContentModel.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/7/21.
//

import Foundation

class ContentModel: ObservableObject {
    
    @Published var modules = [Module]()
    
    var styleData: Data?
    
    init() {
        getLocalData()
    }
    
    func getLocalData() {
        
        // Get url to the json file
        let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json")
        
        
        do {
            // Read file into data object
            let jsonData = try Data(contentsOf: jsonUrl!)
            
            // Try to decode the json into an array of modules
            let jsonDecoder = JSONDecoder()
            let modules = try jsonDecoder.decode([Module].self, from: jsonData)
            
            // Assign parsed modules to modules property
            self.modules = modules
        }
        catch {
            // TODO log error
            print("Couldn't parse local data")
        }
        
        // Parse the style data
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            // Read file into data object
            let styleData = try Data(contentsOf: styleUrl!)
            
            self.styleData = styleData
            
        }
        catch {
            print("Couldn't parse style data")
        }
        
    }
    
}
