//
//  SignInWithGoogle.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 20.01.23.
//

import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var messageError = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                LoginHeader()
                    .padding(100)
                
                Spacer()
                
                GoogleSignInButton{
                    signIn()
                }
                .padding(20)
                
                Button {
                    signInAnonymously()
                } label: {
                    HStack {
                        Spacer()
                        Text("Use anonymous account")
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .frame(height: 40)
                .background(.black)
                .padding()
                
                Spacer()
            }
        }
        .alert(messageError, isPresented: $showError) {
            Button("Ok") { }
        }
    }
    
    func signIn() {
        Task {
            do {
                try await userAuth.signIn()
                userAuth.state = .signedIn
            } catch {
                showError(error: error)
            }
        }
    }
    
    func signInAnonymously() {
        Task {
            do {
                try await userAuth.signInAnonymously()
            } catch {
                showError(error: error)
            }
        }
    }
    
    @MainActor
    func showError(error: Error) {
        messageError = error.localizedDescription
        showError.toggle()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var userAuth = UserAuth()
    
    static var previews: some View {
        SignInView()
            .environmentObject(userAuth)
    }
}
