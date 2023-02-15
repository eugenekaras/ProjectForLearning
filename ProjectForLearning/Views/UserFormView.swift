//
//  UserFormView.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 10.02.23.
//

import SwiftUI

struct UserFormView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State var showingEditProfileView = false
    
    var body: some View {
        let binding = Binding(
            get: { self.userAuth.userProfile },
            set: { self.userAuth.userProfile = $0 }
        )
        ZStack(alignment: .topTrailing){
            HStack {
                UserImage(userProfile: userAuth.userProfile ?? UserProfile.userProfileDefault)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140, alignment: .center)
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(userAuth.userProfile?.user.displayName ?? "")
                        .font(.headline)
                    
                    Text(userAuth.userProfile?.user.email ?? "")
                        .font(.subheadline)
                    
                    Text(userAuth.userProfile?.user.phoneNumber ?? "")
                        .font(.subheadline)
                        .padding(.bottom)
                    
                    Text(userAuth.userProfile?.user.bio ?? "")
                        .font(.footnote)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            buttonEditFormView()
        }
        .sheet(isPresented: $showingEditProfileView) {
            EditProfileView(userProfile: binding) {
                showingEditProfileView = false
            }
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
                self.showingEditProfileView.toggle()
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
