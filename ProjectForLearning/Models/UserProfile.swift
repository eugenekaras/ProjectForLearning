//
//  Profile.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 10.02.23.
//

import SwiftUI

struct UserProfile {
    var userAvatar: UIImage?
    var userData: User
    
    init?(userId: String) async throws {
        if let userData = try await User(userId: userId) {
            self.userData = userData
            if let userAvatar = try await getImage(fileName: userId) {  
                self.userAvatar = userAvatar
            }
            return
        }
        return nil
    }
    
    init(user: User, userAvatar: UIImage?) {
        self.userData = user
        self.userAvatar = userAvatar
    }
    
    func saveProfileData() async throws {
            try await userData.saveUserData()
            
            if let image = userAvatar {
                try await saveImage(image: image, fileName: userData.userId)
            }
    }

    func getImage(fileName: String) async throws -> UIImage? {
        if let directory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: directory.absoluteString).appendingPathComponent("\(fileName).jpg").path)
        }
        return nil
    }
    
    func saveImage(image: UIImage, fileName: String) async throws {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            fatalError("Error converting image to jpeg or png format")
        }
        guard let directory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) as NSURL else {
            fatalError("Error access to app user data")
        }
        
        do {
            try data.write(to: directory.appendingPathComponent("\(fileName).jpg")!)
        } catch {
            print(error.localizedDescription)
        }
    }
}
