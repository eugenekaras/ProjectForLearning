//
//  AuthenticationViewModel.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 21.01.23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase
import FirebaseAuth
import Combine

class UserAuth: ObservableObject {
    
    enum SignInState {
        case unknown
        case signedIn
        case signedOut
    }
    
    @Published var session: User?
    @Published var state: SignInState =  .unknown
    
    func checkSignIn() {
        guard let user = Auth.auth().currentUser else {
            self.session = nil
            self.state = .signedOut
            return
        }
        self.session =  User( userId: user.uid, email: user.email, displayName: user.displayName, url: user.photoURL)
        self.state = .signedIn
    }
    
    func signIn() async throws {
         guard let clientID = FirebaseApp.app()?.options.clientID else {
             fatalError("Firebase SDK is not integrated properly")
         }
         
         let configuration = GIDConfiguration(clientID: clientID)
         GIDSignIn.sharedInstance.configuration = configuration
         
         guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
             fatalError("Error getting UIWindowScene")
         }
         guard let rootViewController = await windowScene.windows.first?.rootViewController else {
             fatalError("Error getting rootViewController")
         }
         
         let signResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
         try await authenticateUser(for: signResult.user)
     }
    
    func signInAnonymously() async throws {
        let authResult = try await Auth.auth().signInAnonymously()

        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.session = User(
                userId: authResult.user.uid,
                email: authResult.user.email,
                displayName: authResult.user.displayName,
                url: authResult.user.photoURL
            )
            self.state = .signedIn
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser) async throws {
        let accessToken = user.accessToken
        guard let idToken = user.idToken else {
            fatalError("Error getting idToken")
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        let authResult =  try await Auth.auth().signIn(with: credential)
        
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.session =  User(
                userId: authResult.user.uid,
                email: authResult.user.email,
                displayName: authResult.user.displayName,
                url: authResult.user.photoURL
            )
            self.state = .signedIn
        }
    }
    
    func signOut() async throws {
        let firebaseAuth = Auth.auth()
        try firebaseAuth.signOut()
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.session = nil
            self.state = .signedOut
        }
    }
    
    func deleteUserOld()  async throws {
        guard let user = Auth.auth().currentUser else {
            fatalError("Error getting current user for delete")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.session = nil
            self.state = .signedOut
        }
        try await user.delete()
    }
    
    func deleteUser() async throws {
        if let user = Auth.auth().currentUser {
            
            let idToken =  try await user.getIDToken()
            let accessToken = try await user.idTokenForcingRefresh(true)
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            try await user.reauthenticate(with: credential)
            
            try await user.delete()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.session = nil
            self.state = .signedOut
        }
    }
}

