//
//  ProjectForLearningApp.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 18.01.23.
//

import SwiftUI
import Firebase

@main
struct ProjectForLearningApp: App {
    @StateObject var appState = AppState()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.userAuth)
        }
    }
}
