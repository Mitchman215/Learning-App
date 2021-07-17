//
//  ContentModel.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/7/21.
//

import Foundation

class ContentModel: ObservableObject {
    
    // List of modules
    @Published var modules = [Module]()
    
    // Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Curent lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    // Current lesson/ quiz explanation
    @Published var codeText = NSAttributedString()
    var styleData: Data?
    
    // Current question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current selected content and test
    @Published var currentContentSelected:Int?
    @Published var currentTestSelected:Int?
    
    init() {
        // Parse local included json data
        getLocalData()
        
        // Download remote json file and parse data
        getRemoteData()
    }
    
    // MARK: - Data methods
    
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
    
    func getRemoteData() {
        
        // String path
        let urlString = "https://mitchman215.github.io/Learning-App-data/data2.json"
        
        // Create a url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            // Couldn't cretae url
            return
        }
        
        // Create a URLRequest object
        let request = URLRequest(url: url!)
        
        // Get the session and kick off the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // Check if there's an error
            guard error == nil else {
                // There was an error
                return
            }
            
            do {
                // Create json decoder
                let decoder = JSONDecoder()
                // Decode
                let modules = try decoder.decode([Module].self, from: data!)
                
                // asign code to main thread
                // all code that updates the ui should be in the main thread
                DispatchQueue.main.async {
                    // Append parsed modules into modules property
                    self.modules += modules
                }
                
            }
            catch {
                // Couldn't parse json
                
            }
            
            
        }
        
        // Kick off data task, don't forget
        dataTask.resume()
    }
    
    // MARK: - Module navigation methods
    
    func beginModule(_ moduleid: Int) {
        
        // Find the index for this module id
        for index in 0..<modules.count {
            if modules[index].id == moduleid {
                // Found the matching module
                currentModuleIndex = index
                break
            }
        }
        
        // Set the current module
        currentModule = modules[currentModuleIndex]
    }
    
    func beginLesson(_ lessonIndex: Int) {
        // Check that the lesson is within range of module lessons
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex = lessonIndex
        }
        else {
            currentLessonIndex = 0
        }
        
        // Set the current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        // Set lesson explanation
        codeText = addStyling(currentLesson!.explanation)
    }
    
    func hasNextLesson() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    func nextLesson() {
        // Check that there is a next lesson
        if self.hasNextLesson() {
            // Advance the lesson index
            currentLessonIndex += 1
            // set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
        }
        else {
            // Reset the lesson state
            currentLessonIndex = 0
            currentLesson = nil
        }
        
    }
    
    func beginTest(_ moduleid:Int) {
        // Set the current module
        beginModule(moduleid)
        
        // Set the current question
        currentQuestionIndex = 0
        
        // if there are questions, set the current question to the first one
        if currentModule?.test.questions.count ?? 0 > 0 {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            // set the question content
            codeText = addStyling(currentQuestion!.content)
        }
    }
    
    func hasNextQuestion() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentQuestionIndex + 1 < currentModule!.test.questions.count)
    }
    
    func nextQuestion() {
        if self.hasNextQuestion() { // if it isn't the last question
            // advance question index
            currentQuestionIndex += 1
            // set the new current question
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
            }
        else { // TODO: Check if this code is ever executed, maybe make into an exception
            // Reset the question if it is the last
            currentQuestionIndex = 0
            currentQuestion = nil
            
        }
    }
    
    // MARK: - Code Styling
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        if styleData != nil {
            // Add the styling data
            data.append(self.styleData!)
        }
        
        // Add html data
        data.append(Data(htmlString.utf8))
        
        // Convert attributed string
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            resultString = attributedString
        }
        
        return resultString
    }
    
}
