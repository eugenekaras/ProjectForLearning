//
//  EditProfileView.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 9.02.23.
//

import SwiftUI

struct EditProfileView: View {
    @State var userProfile: UserProfile
    @State var mode: EditMode = .inactive
    @Namespace private var namespace
    
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {
        NavigationView {
            Group {
                if mode.isEditing {
                    editFormView()
                } else {
                    formView()
                }
            }
//            .animation(.default, value: mode)
            .navigationTitle("Profile")
            .navigationBarItems(
                leading: HStack{
                    if mode == .active {
                        Button("Cancel") {
                            mode = .inactive
                        }
                    } else if mode == .inactive  {
                        Button("Back") {
                            viewState.contentViewState = .signIn
                        }
                    }
                },
                trailing: HStack{
                    EditButton()
                }
            )
            .environment(\.editMode, self.$mode)
        }
    }
    
    
    
    private func formView() -> some View {
        return Form{
            Section(header: Text("My info")) {
                HStack {
                    Text("First name:")
                    Spacer()
                    Text(userProfile.userData.firstName).foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Last name:")
                    Spacer()
                    Text(userProfile.userData.lastName).foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Email:")
                    Spacer()
                    Text(userProfile.userData.email).foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Phone:")
                    Spacer()
                    Text(userProfile.userData.phoneNumber).foregroundColor(.secondary)
                }
            }
            
        }
    }

    private func editFormView() -> some View {
        return Form{
            
            Section(header: Text("First name")) {
                TextField("first name",text: $userProfile.userData.firstName)
            }
            Section(header: Text("Last name")) {
                TextField("Last name",text: $userProfile.userData.lastName)
            }
            Section(header: Text("Email")) {
                TextField("Email",text: $userProfile.userData.email)
            }
            Section(header: Text("Phone")) {
                TextField("Phone",text: $userProfile.userData.phoneNumber)
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(userProfile: UserProfile(user: User(
            userId: "12345",
            email: "someemail@gmail.com",
            displayName: "Tom Kruz",
            phoneNumber: "12345",
            url: nil),
             userAvatar: nil))
    }
}
