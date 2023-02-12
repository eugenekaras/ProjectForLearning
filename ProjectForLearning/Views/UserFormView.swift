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
                UserImage(userProfile: userAuth.userProfile ?? USER_DEFAULT)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140, alignment: .center)
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(userAuth.userProfile?.userData.displayName ?? "")
                        .font(.headline)
                        .padding(.bottom)
                    
                    Text(userAuth.userProfile?.userData.email ?? "")
                        .font(.subheadline)
                    
                    Text(userAuth.userProfile?.userData.phoneNumber ?? "")
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
    static var viewState = ViewState()
    
    static var previews: some View {
        UserFormView()
            .environmentObject(userAuth)
            .environmentObject(viewState)
    }
}
