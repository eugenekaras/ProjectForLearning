//
//  TopItemProfile.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 20.01.23.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    enum ProfileViewError: LocalizedError {
        case unknownError(error: Error)
        var errorDescription: String? {
            switch self {
            case .unknownError(let error):
                return error.localizedDescription
            }
        }
    }
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var isShowingActionSheet = false
    @State private var isShowingDeleteUserDialog = false
    @State private var showError = false
    @State private var error: ProfileViewError? = .unknownError(error: NSError(domain: "Test", code: 1) as Error)
    let ERROR_REQUIRES_RECENT_LOGIN = 17014
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    UserImage(url: userAuth.user?.url)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                        .cornerRadius(8)
                    VStack(alignment: .leading) {
                        Text(userAuth.user?.displayName ?? "Anonymous")
                            .font(.headline)
                        
                        Text(userAuth.user?.email ?? "")
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
                
                Spacer()
                
                Text("Hello, from Profile!")
                
                Spacer()
                
                Button  {
                    self.isShowingActionSheet = true
                } label: {
                    Text("Sign out")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemIndigo))
                        .cornerRadius(13)
                        .padding()
                }
                .actionSheet(isPresented: $isShowingActionSheet) {
                    ActionSheet(title: Text("Confirm your actions"),
                                message: Text("Are you su re you want to log out of your profile?"),
                                buttons: [.default(Text("Delete account"),
                                                   action: {
                        deleteUser()
                    }),.destructive(Text("Sign out"),action: {
                        signOut()
                    })
                                          ,.cancel()])
                }
            }
            .alert(isPresented: $showError, error: error, actions: {})
            .confirmationDialog("Are you sure you want to delete your account?", isPresented: $isShowingDeleteUserDialog, actions: {
                Button("Delete", role: .destructive) {
                    reauthenticateAndDeleteUser()
                }
                Button("No", role: .cancel) {
                    isShowingDeleteUserDialog = false
                }
            })
        }
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
        switch error.code {
        case ERROR_REQUIRES_RECENT_LOGIN:
            self.isShowingDeleteUserDialog.toggle()
        default:
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
