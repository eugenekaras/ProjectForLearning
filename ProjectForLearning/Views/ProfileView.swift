//
//  TopItemProfile.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 20.01.23.
//
import SwiftUI
import FirebaseAuth

enum ProfileViewError: LocalizedError {
    case unknownError(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .unknownError(let error):
            return error.localizedDescription
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var showSignOutActionSheet = false
    @State private var showDialogForUserDelete = false
    @State private var showError = false
    @State private var error: ProfileViewError?
    
    var body: some View {
        VStack {
            UserFormView()
            Spacer()
            
            Text("Hello, from Profile!")
            Spacer()
            
            Button  {
                self.showSignOutActionSheet = true
            } label: {
                Text("Sign out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemIndigo))
                    .cornerRadius(13)
                    .padding()
            }
        }
        .actionSheet(isPresented: $showSignOutActionSheet) {
            signOutActionSheet
        }
        .alert(isPresented: $showError, error: error, actions: {})
        .confirmationDialog("Are you sure you want to delete your account?", isPresented: $showDialogForUserDelete, actions: {
            Button("Delete", role: .destructive) {
                reauthenticateAndDeleteUser()
            }
            Button("Cancel", role: .cancel) {
                showDialogForUserDelete = false
            }
        })
    }
    
    var signOutActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Confirm your actions"),
            message: Text("Are you su re you want to log out of your profile?"),
            buttons: [
                .default(Text("Delete account")) {
                    deleteUser()
                },
                .destructive(Text("Sign out")) {
                    signOut()
                },
                .cancel()
            ]
        )
    }

    func deleteUser() {
        Task {
            do {
                try await userAuth.deleteUser()
            } catch {
                showError(error: error)
            }
        }
    }
    func reauthenticateAndDeleteUser() {
        Task {
            do {
                try await userAuth.reauthenticate()
                try await userAuth.deleteUser()
            } catch {
                showError(error: error)
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await userAuth.signOut()
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
        let code = AuthErrorCode(_nsError: error).code
        if code == .requiresRecentLogin {
            self.showDialogForUserDelete.toggle()
        } else {
            self.error = ProfileViewError.unknownError(error: error)
            self.showError.toggle()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var userAuth = UserAuth()
    
    static var previews: some View {
        ProfileView()
            .environmentObject(userAuth)
    }
}
