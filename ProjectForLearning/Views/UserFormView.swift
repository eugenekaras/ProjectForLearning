//
//  UserFormView.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 10.02.23.
//

import SwiftUI

struct UserFormView: View {
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            HStack {
                UserImage(url: userAuth.userProfile?.userData.url)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140, alignment: .center)
                    .cornerRadius(8)
//                    .clipShape(Capsule())
                VStack(alignment: .leading) {
                    Text(userAuth.userProfile?.userData.displayName ?? "123")
                        .font(.headline)
                        .padding(.bottom)
                    
                    Text(userAuth.userProfile?.userData.email ?? "123")
                        .font(.subheadline)
                    
                    Text(userAuth.userProfile?.userData.phoneNumber ?? "123")
                        .font(.subheadline)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            buttonEditFormView()
        }
        .padding()
    }
    
    private func buttonEditFormView() -> some View {
        return Image(systemName: "pencil")
            .font(.title)
            .padding(5)
            .background(Color(.systemIndigo))
            .foregroundColor(Color.white)
            .clipShape(Capsule())
            .padding()
            .onTapGesture {
                viewState.contentViewState = .editUserData
            }
    }
}

struct UserFormView_Previews: PreviewProvider {
    static var userAuth = UserAuth()

    static var previews: some View {
        UserFormView()
            .environmentObject(userAuth)
    }
}
