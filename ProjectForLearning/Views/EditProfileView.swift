//
//  EditProfileView.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 9.02.23.
//

import SwiftUI
import PhotosUI

enum EditProfileError: LocalizedError {
    case unknownError(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .unknownError(let error):
            return error.localizedDescription
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var showError = false
    @State private var error: EditProfileError?
    @State var userProfile: UserProfile
    @State var mode: EditMode = .inactive
    @State private var showChangePhotoConfirmationDialog = false
    @State private var selectPhotoData: Data?
    @State private var selectPhotosPickerItem: PhotosPickerItem?
    @State var showPhotosPicker: Bool = false
    @State var showCamera: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                if mode.isEditing {
                    editFormView()
                } else {
                    formView()
                }
            }
            .animation(.default, value: mode)
            .navigationTitle("Profile")
            .navigationBarItems(
                leading: HStack{
                    if mode == .active {
                        Button("Cancel") {
                            if let userProfile = userAuth.userProfile {
                                self.userProfile = userProfile
                            }
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
            .onChange(of: mode) { _ in
                saveChangeDate()
            }
        }
    }
    
    private func formView() -> some View {
        return Form{
            Section(header: Text("My foto")) {
                HStack {
                    UserImage(userProfile: userAuth.userProfile ?? USER_DEFAULT)
                }
            }
            Section(header: Text("My info")) {
                HStack {
                    Text("First name:")
                    Spacer()
                    Text(userAuth.userProfile?.userData.firstName ?? "").foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Last name:")
                    Spacer()
                    Text(userAuth.userProfile?.userData.lastName ?? "").foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Email:")
                    Spacer()
                    Text(userAuth.userProfile?.userData.email ?? "").foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Phone:")
                    Spacer()
                    Text(userAuth.userProfile?.userData.phoneNumber ?? "").foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func editFormView() -> some View {
        return Form{
            Section(header: Text("My foto")) {
                ZStack(alignment: .topTrailing){
                    HStack{
                        UserImage(userProfile: userProfile)
                    }
                    buttonChangePhotoView()
                }
            }
            .confirmationDialog(Text("change photo"), isPresented: $showChangePhotoConfirmationDialog, titleVisibility: .hidden) {
                Button("Take a picture") {
                    print("Take a picture")
                }
                Button("Сhoose from gallery") {
                    showPhotosPicker.toggle()
                }
                Button("Cancel", role: .cancel) {
                    self.showChangePhotoConfirmationDialog.toggle()
                }
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectPhotosPickerItem, matching: .any(of: [.images, .screenshots]))
            .onChange(of: selectPhotosPickerItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            userProfile.userAvatar = uiImage
                        }
                    }
                }
            }
            
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
    
    private func buttonChangePhotoView() -> some View {
        return Image(systemName: "camera.circle.fill")
            .resizable()
            .frame(width: 60, height: 60)
            .background(Color(.white))
            .foregroundColor(Color(.systemIndigo))
            .clipShape(Capsule())
            .padding()
            .onTapGesture {
                self.showChangePhotoConfirmationDialog.toggle()
            }
    }
    
    private func photosPicker() -> some View {
        return PhotosPicker("Select images", selection: $selectPhotosPickerItem, matching: .images)
    }
    
    func saveChangeDate() {
        userAuth.userProfile = self.userProfile
        
        Task {
            do {
                try await userAuth.userProfile?.saveProfileData()
            } catch {
                showError(error: error)
            }
        }
    }
    
    @MainActor
    func showError(error: Error) {
        guard let error = error as NSError? else {
            fatalError("Unknown error")
        }
        self.error = EditProfileError.unknownError(error: error)
        self.showError.toggle()
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var userAuth = UserAuth()
    static var viewState = ViewState()
    
    static var previews: some View {
        EditProfileView(userProfile: UserProfile(user: User(
            userId: "12345",
            email: "someemail@gmail.com",
            displayName: "Tom Kruz",
            phoneNumber: "12345",
            url: nil), userAvatar: nil)
        )
        .environmentObject(userAuth)
        .environmentObject(viewState)
    }
}
