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
    @State private var showError = false
    @State private var error: EditProfileError?
    @State var mode: EditMode = .active
    @State private var showChangePhotoConfirmationDialog = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    @State private var image: UIImage?
    @State var tmpUserProfile: UserProfile = UserProfile.userProfileDefault
    @Binding var userProfile: UserProfile?
    
    var dismissEditProfileView: () -> Void
    
    var body: some View {
        NavigationView {
            Group {
                editFormView()
            }
            .animation(.default, value: mode)
            .navigationTitle("Profile")
            .navigationBarItems(
                leading: HStack{
                    Button("Cancel") {
                        if let userProfile = userProfile {
                            tmpUserProfile = userProfile
                        }
                        dismissEditProfileView()
                        mode = .inactive
                    }
                },
                trailing: HStack{
                    EditButton()
                }
            )
            .environment(\.editMode, self.$mode)
            .onChange(of: mode) { _ in
                saveChangeDate()
                dismissEditProfileView()
            }
        }
        .onAppear() {
            if let userProfile = userProfile {
                tmpUserProfile = userProfile
            }
        }
    }
    
    private func editFormView() -> some View {
        return Form{
            Section(header: Text("My foto")) {
                ZStack(alignment: .topTrailing){
                    HStack{
                        UserImage(userProfile: tmpUserProfile)
                    }
                    buttonChangePhotoView()
                }
                .confirmationDialog(Text("change photo"), isPresented: $showChangePhotoConfirmationDialog, titleVisibility: .hidden) {
                    Button("Camera") {
                        self.shouldPresentImagePicker = true
                        self.shouldPresentCamera = true
                    }
                    Button("Photo Library") {
                        self.shouldPresentImagePicker = true
                        self.shouldPresentCamera = false
                    }
                    Button("Cancel", role: .cancel) {
                        showChangePhotoConfirmationDialog.toggle()
                    }
                }
                .sheet(isPresented: $shouldPresentImagePicker) {
                    ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, image: self.$image, isPresented: self.$shouldPresentImagePicker)
                }
                .onChange(of: self.image) { newValue in
                    if let uiImage = newValue {
                        tmpUserProfile.userAvatar = uiImage
                    }
                }
            }
            
            Section(header: Text("First name")) {
                TextField("first name",text: $tmpUserProfile.user.firstName)
            }
            Section(header: Text("Last name")) {
                TextField("Last name",text: $tmpUserProfile.user.lastName)
            }
            Section(header: Text("Email")) {
                TextField("Email",text: $tmpUserProfile.user.email)
                    .keyboardType(.emailAddress)
            }
            Section(header: Text("Phone")) {
                TextField("Phone",text: $tmpUserProfile.user.phoneNumber)
                    .keyboardType(.phonePad)
            }
            Section(header: Text("Bio")) {
                TextEditor(text: $tmpUserProfile.user.bio)
                    .multilineTextAlignment(.leading)
                    .disableAutocorrection(true)
                    .frame(height: 200)
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
    
    func saveChangeDate() {
        userProfile = tmpUserProfile
        
        Task {
            do {
                try await userProfile?.saveProfileData()
            } catch {
                await showError(error: error)
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
    static var previews: some View {
        EditProfileView( userProfile: Binding(
            get: { UserProfile.userProfileDefault },
            set: { UserProfile.userProfileDefault = $0!})) { }
    }
}
