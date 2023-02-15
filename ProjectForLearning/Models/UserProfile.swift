//
//  Profile.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 10.02.23.
//

import SwiftUI

struct UserProfile {
    static var userProfileDefault: UserProfile = UserProfile(user: User(userId: "12345", email: "", displayName: "", phoneNumber: "", url: nil), userAvatar: nil)
    var userAvatar: UIImage?
    var user: User
    
    private var url: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("\(self.user.userId).jpg")
    }
    
    init?(userId: String) async throws {
        if let userData = try await User(userId: userId) {
            self.user = userData
            loadUserAvatar()
            return
        }
        return nil
    }
    
    init(user: User, userAvatar: UIImage?) {
        self.user = user
        self.userAvatar = userAvatar
    }
    
    func saveProfileData() async throws {
        try await user.saveUserData()
        saveUserAvatar()
    }
    
    mutating func loadUserAvatar(){
        if let data = try? Data(contentsOf: url), let loaded = UIImage(data: data) {
            userAvatar = loaded
        } else {
            userAvatar = nil
        }
    }
    
    func saveUserAvatar() {
        if let image = userAvatar {
            if let data = image.jpegData(compressionQuality: 1.0) {
                try? data.write(to: url)
            }
        } else {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
