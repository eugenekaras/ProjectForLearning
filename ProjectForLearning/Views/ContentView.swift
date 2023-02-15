//
//  ContentView.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 18.01.23.
//

import SwiftUI

enum ContentViewError: LocalizedError {
    case unknownError(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .unknownError(let error):
            return error.localizedDescription
        }
    }
}

enum ContentViewState {
    case splash
    case greeting
    case signIn
    case signOut
}

struct ContentView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var showError = false
    @State private var error: ContentViewError?
    @State private var contentViewState: ContentViewState = .splash
    
    var body: some View {
        Group {
            switch contentViewState {
            case .splash: SplashScreenView()
            case .greeting: GreetingPageView()
            case .signIn: MainTabBarView()
            case .signOut: SignInView()
            }
        }
        .animation(.default, value: contentViewState)
        .task {
            checkUser()
        }
        .onChange(of: userAuth.state) { newValue in
            updateViewState(with: newValue)
        }
    }
    
    func updateViewState(with signInState: UserAuth.SignInState) {
        if (contentViewState == .signOut) && (signInState == .signedIn) {
            contentViewState = .greeting
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                contentViewState = .signIn
            }
        } else {
            switch signInState {
            case .unknown: contentViewState = .splash
            case .signedIn: contentViewState = .signIn
            case .signedOut: contentViewState = .signOut
            }
        }
    }
    
    func checkUser() {
        Task {
            do {
                try await userAuth.updateUserProfile()
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
        self.error = ContentViewError.unknownError(error: error)
        self.showError.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var userAuth = UserAuth()
    
    static var previews: some View {
        ContentView()
            .environmentObject(userAuth)
    }
}
