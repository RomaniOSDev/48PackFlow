//
//  AchievementsView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress Header
                        VStack(spacing: 12) {
                            Text("Achievements")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                            
                            Text("\(viewModel.unlockedCount) of \(viewModel.totalCount) unlocked")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 10)
                                        .cornerRadius(5)
                                    
                                    Rectangle()
                                        .fill(Color.appAccent)
                                        .frame(width: geometry.size.width * (Double(viewModel.unlockedCount) / Double(viewModel.totalCount)), height: 10)
                                        .cornerRadius(5)
                                }
                            }
                            .frame(height: 10)
                            .padding(.horizontal, 40)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Achievements Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Achievements")
            .overlay(
                // Recently Unlocked Toast
                VStack {
                    if !viewModel.recentlyUnlocked.isEmpty {
                        ForEach(viewModel.recentlyUnlocked) { achievement in
                            AchievementToast(achievement: achievement)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    Spacer()
                }
                .animation(.spring(), value: viewModel.recentlyUnlocked.count)
            )
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.appAccent.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(achievement.isUnlocked ? .appAccent : .gray)
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appAccent)
                        .offset(x: 30, y: 30)
                }
            }
            
            VStack(spacing: 4) {
                Text(achievement.type.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .appText : .gray)
                    .multilineTextAlignment(.center)
                
                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

struct AchievementToast: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.type.icon)
                .font(.title2)
                .foregroundColor(.appAccent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                    .font(.headline)
                    .foregroundColor(.appText)
                
                Text(achievement.type.title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.top, 60)
    }
}

#Preview {
    AchievementsView()
}
