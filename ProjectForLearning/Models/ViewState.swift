//
//  ViewState.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 10.02.23.
//

import Foundation

enum ContentViewState {
    case splash
    case greeting
    case signIn
    case signOut
    case editUserData
}

class ViewState : ObservableObject {
    @Published var contentViewState = ContentViewState.splash
}
