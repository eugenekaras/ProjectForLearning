//
//  Data.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 20.01.23.
//

import Foundation

class AppState : ObservableObject {
    var viewState = ViewState()
    var userAuth = UserAuth()
}
