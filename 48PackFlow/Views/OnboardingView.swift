//
//  OnboardingView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == currentPage ? Color.appAccent : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Content
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        imageName: "bag.fill",
                        title: "Smart Packing",
                        description: "Create personalized packing lists for your workouts, trips, and competitions. Never forget essential gear again."
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        imageName: "square.grid.2x2",
                        title: "Gear Catalog",
                        description: "Manage your sports equipment inventory. Scan barcodes or add items manually. Track what's packed and what's not."
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        imageName: "chart.bar.fill",
                        title: "Track Progress",
                        description: "Monitor your packing progress with visual indicators. Use templates or create custom flows for different activities."
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Previous")
                                .foregroundColor(.appText)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage < 2 ? "Next" : "Get Started")
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.appAccent)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.appAccent)
            
            // Text Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
