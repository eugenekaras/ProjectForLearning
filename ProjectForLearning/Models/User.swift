//
//  User.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 1.02.23.
//

import Foundation

struct User: Codable {
    var userId: String
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var bio: String = ""
    var url: URL?
    
    var displayName: String? {
        get {
            return firstName.capitalized + " " + lastName.capitalized
        }
        set {
            if let array = newValue?.components(separatedBy: " ") {
                if array.count == 1 {
                    firstName = array[0]
                } else {
                    firstName = array[0]
                    lastName = array[1]
                }
            }
        }
    }

    init(userId: String, email: String?, displayName: String?, phoneNumber: String?, url: URL?) {
        self.userId = userId
        if let email = email {
            self.email = email
        }
        if let displayName = displayName {
            self.displayName = displayName
        }
        if let phoneNumber = phoneNumber {
            self.phoneNumber = phoneNumber
        }
        self.url = url
    }
    
    init?(userId: String) async throws {
        if let data = UserDefaults.standard.data(forKey: userId) {
            if let user = try? JSONDecoder().decode(User.self, from: data) {
                self = user
                return
            }
        }
        return nil
    }
    
    func saveUserData() async throws {
        if let user = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(user, forKey: userId)
        }
    }
}
