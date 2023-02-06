//
//  User.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 1.02.23.
//

import Foundation
import FirebaseAuth

struct User {
    var userId: String
    var email: String?
    var displayName: String?
    var url: URL?

    init(userId: String, email: String?, displayName: String?, url: URL?) {
        self.userId = userId
        self.email = email
        self.displayName = displayName
        self.url = url
    }
    
//    func saveCredential(credential: AuthCredential?) {
//        let defaults = UserDefaults.standard
//        defaults.set(credential, forKey: "credential")
//    }
    
//    func getCredential() -> AuthCredential {
//        let defaults = UserDefaults.standard
//        return defaults.object(forKey: "credential") as! AuthCredential
//    }
}
