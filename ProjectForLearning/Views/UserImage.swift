//
//  NetworkImage.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 3.02.23.
//

import SwiftUI

struct UserImage: View {
    var userProfile: UserProfile
    
    var body: some View {
        if let uiImage = userProfile.userAvatar {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let url = userProfile.user.url {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct NetworkImage_Previews: PreviewProvider {
    static var previews: some View {
        UserImage(userProfile: UserProfile.userProfileDefault)
    }
}
