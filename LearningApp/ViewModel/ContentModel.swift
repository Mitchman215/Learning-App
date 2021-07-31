//
//  ContentModel.swift
//  LearningApp
//
//  Created by Mitchell Salomon on 7/7/21.
//

import Foundation
import Firebase

class ContentModel: ObservableObject {
    
    let DB = Firestore.firestore()
    
    // Boolean indicating if user is logged in
    @Published var loggedIn = false
    @Published var accountError: String?
    
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
    private var styleData: Data?
    
    // Current question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current selected content and test
    @Published var currentContentSelected:Int?
    @Published var currentTestSelected:Int?
    
    init() {
        // Parse local style.html
        getLocalStyles()
    }
    
    // MARK: - Authentication methods
    
    /// Method that checks whether the user is logged in and gets their meta data if it is not retrieved already
    func checkLogin() {
        // Check if there's a current user to determine logged in status
        loggedIn = Auth.auth().currentUser != nil
        
        // Check if user meta data has been fetched
        // If not, call getUserData
        if UserService.shared.user.name == "" {
            getUserData()
        }
    }
    
    /// Method to log the user in given their email address and password as Strings
    /// Returns an optional error message that will contain the error message if there is one, otherwise nil
    func login(email: String, password: String) {
        // Clear the error message
        self.accountError = nil
        
        // Log the user in
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            // Check for errors
            guard error == nil else {
                // If there is an error, set the account error message
                self.accountError = error!.localizedDescription
                return
            }
            
            // Update the loggedIn property flag and get the user's meta data
            self.checkLogin()
        }
    }
    
    /// Method to create a new account given the user's email address, name, and password as strings
    /// Updates accountError property to store the error message if there is one
    func createAccont(email: String, name: String, password: String) {
        // Clear the error message
        self.accountError = nil
        
        // Create a new account
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            // Check for errors
            guard error == nil else {
                self.accountError = error!.localizedDescription
                return
            }
            
            // Save the first name to the database
            let firebaseUser = Auth.auth().currentUser
            self.DB.collection("users").document(firebaseUser!.uid)
                .setData(["name":name], merge: true)
            
            // Update the user meta data
            let user = UserService.shared.user
            user.name = name
            
            // Update the loggedIn property flag
            self.checkLogin()
        }
    }
    
    // MARK: - Data methods
    
    /// Method to retrieve the user's meta data and store it in the UserService's user object
    private func getUserData() {
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        // Get the meta data for that user
        let ref = DB.collection("users").document(Auth.auth().currentUser!.uid)
        ref.getDocument { (snapshot, error) in
            // Check there's no errors
            guard error == nil, snapshot != nil else {
                return
            }
            
            // Parse the data out and set the user meta data
            let data = snapshot!.data()
            let user = UserService.shared.user
            user.name = data?["name"] as? String ?? ""
            user.lastModule = data?["lastModule"] as? Int
            user.lastLesson = data?["lastLesson"] as? Int
            user.lastModule = data?["lastQuestion"] as? Int
        }
    }
    
    /// Method to retrive a module's lessons and store them in the modules array under the appropriate module
    /// executes completion after the lessons are retrieved
    func getLessons(module: Module, completion: @escaping () -> Void) {
        // Specify path
        let collection = DB.collection("modules").document(module.id).collection("lessons")
        
        // Get documents
        collection.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                
                // Array to track lessons
                var lessons = [Lesson]()
                
                // Loop through the documents and build array of lessons
                for doc in snapshot!.documents {
                    var l = Lesson()
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    lessons.append(l)
                }
                
                // Setting the lessons to the module
                // Loop through published modules array to find match
                for (index, m) in self.modules.enumerated() {
                    if m.id == module.id {
                        self.modules[index].content.lessons = lessons
                        
                        // Call completion closure
                        completion()
                        return
                    }
                }
            }
        }
    }
    
    /// Method to retrieve a module's test questions and store them in the modules array under the appropriate module
    /// executes completion after the lessons are retrieved
    func getQuestions(module: Module, completion: @escaping () -> Void) {
        
        let collection = DB.collection("modules").document(module.id).collection("questions")
        
        collection.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                
                // Array to track questions
                var questions = [Question]()
                
                // Loop through the documents and build array of lessons
                for doc in snapshot!.documents {
                    var q = Question()
                    q.id = doc["id"] as? String ?? UUID().uuidString
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.answers = doc["answers"] as? [String] ?? [String]()
                    questions.append(q)
                }
                
                // Setting the lessons to the module
                // Loop through published modules array to find match
                for (index, m) in self.modules.enumerated() {
                    if m.id == module.id {
                        self.modules[index].test.questions = questions
                        
                        // Call completion closure
                        completion()
                        return
                    }
                }
            }
        }
    }
    
    /// Method to retrieve the basic modules information stored in the database. Each module's Lessons and Questions are retrieved separately
    func getDatabaseModules() {
        // Specify path
        let collection = DB.collection("modules")
        
        // Get documents
        collection.getDocuments { (snapshot, error) in
            
            // If there are no errors
            if error == nil && snapshot != nil {
                
                // Create an array for the modules
                var modules = [Module]()
                
                // Loop through the documents returned
                for doc in snapshot!.documents {
                    
                    // Parse out the data from the document into variables
                    
                    // Create a new module instance
                    var m = Module()
                    
                    // Parse out the values from the document into the module instance
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    // Parse the lesson content
                    let contentMap = doc["content"] as! [String:Any]
                    
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""

                    
                    // Parse the test content
                    let testMap = doc["test"] as! [String:Any]
                    m.test.id = testMap["id"] as? String ?? ""
                    m.test.description = testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                    
                    // Add it to our array
                    modules.append(m)
                    
                }
                
                // Assign our modules to the published property
                DispatchQueue.main.async {
                    self.modules = modules
                }
            }
            
        }
        
    }
    
    /// Method to parse the local style.html file
    func getLocalStyles() {        
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
    
    /// defunct, leave for reference purposes. delete before production
    private func getRemoteData() {
        
        // String path
        let urlString = "https://mitchman215.github.io/Learning-App-data/data2.json"
        
        // Create a url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            // Couldn't create url
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
    
    /// Method that starts the specified module, given a module ID
    func beginModule(_ moduleid: String) {
        
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
    
    /// Method that starts the lessons in the current module, given a lesson index
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
    
    /// Method to check whether there is a next lesson in the module
    /// returns true if there is a next lesson, false otherwise
    func hasNextLesson() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    /// Method to advance the current lesson to the next lesson
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
    
    /// Method that starts the test in the current module, given the module ID
    // TODO: make signature consistent with begin lesson
    func beginTest(_ moduleid:String) {
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
    
    /// Method to check whether there is a next question in the module
    /// returns true if there is a next question, false otherwise
    func hasNextQuestion() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentQuestionIndex + 1 < currentModule!.test.questions.count)
    }
    
    /// Method to advance the current question to the next question
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
    
    /// Converts a String of html code into an NSAttributedString by using styleData
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
