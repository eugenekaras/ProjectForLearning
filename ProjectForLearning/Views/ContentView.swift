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

struct ContentView: View {
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var viewState: ViewState
    
    @State private var showError = false
    @State private var error: ContentViewError?
    
    var body: some View {
        Group {
            switch viewState.contentViewState {
            case .splash: SplashScreenView()
            case .greeting: GreetingPageView()
            case .signIn: MainTabBarView()
            case .signOut: SignInView()
            case .editUserData: EditProfileView(userProfile: userAuth.userProfile ?? USER_DEFAULT)
            }
        }
        .animation(.default, value: viewState.contentViewState)
        .task {
            checkUser()
        }
        .onChange(of: userAuth.state) { newValue in
            updateViewState(with: newValue)
        }
    }
    
    func updateViewState(with signInState: UserAuth.SignInState) {
        if (viewState.contentViewState == .signOut) && (signInState == .signedIn) {
            viewState.contentViewState = .greeting
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                viewState.contentViewState = .signIn
            }
        } else {
            switch signInState {
            case .unknown: viewState.contentViewState = .splash
            case .signedIn: viewState.contentViewState = .signIn
            case .signedOut: viewState.contentViewState = .signOut
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
