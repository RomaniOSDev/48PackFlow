//
//  ContentView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        ZStack {
            HomeView()
                .opacity(showOnboarding ? 0 : 1)
            
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showOnboarding)
    }
}

#Preview {
    ContentView()
}
