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
    
    private var urlForUserAvatar: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("\(self.userData.userId).jpg")
    }
    
    init?(userId: String) async throws {
        if let userData = try await User(userId: userId) {
            self.userData = userData
            urlForUserAvatar.loadImage(&userAvatar)
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
            urlForUserAvatar.saveImage(image)
        }
    }
}
