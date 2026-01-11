//
//  HomeView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var gearCatalogViewModel = GearCatalogViewModel()
    @StateObject private var achievementViewModel = AchievementViewModel()
    @State private var selectedTab = 0
    @State private var showFlowBuilder = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MyPacksView(homeViewModel: homeViewModel, showFlowBuilder: $showFlowBuilder)
                .tabItem {
                    Label("My Packs", systemImage: "bag.fill")
                }
                .tag(0)
            
            GearCatalogView(viewModel: gearCatalogViewModel)
                .tabItem {
                    Label("Catalog", systemImage: "square.grid.2x2")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.appAccent)
        .sheet(isPresented: $showFlowBuilder) {
            FlowBuilderView(
                viewModel: FlowBuilderViewModel(
                    homeViewModel: homeViewModel,
                    gearCatalogViewModel: gearCatalogViewModel
                ),
                achievementViewModel: achievementViewModel
            )
        }
        .onAppear {
            achievementViewModel.updateDailyActivity()
            achievementViewModel.checkFlowCountAchievements(flowCount: homeViewModel.activeFlows.count)
            achievementViewModel.checkCatalogMasterAchievement(itemCount: gearCatalogViewModel.gearItems.count)
            achievementViewModel.checkCustomFlowCreatorAchievement(customFlowCount: homeViewModel.getCustomFlowsCount())
        }
    }
}

struct MyPacksView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Binding var showFlowBuilder: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Active Flows Section
                        if !homeViewModel.activeFlows.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Flows")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appText)
                                    .padding(.horizontal)
                                
                                ForEach(homeViewModel.activeFlows) { flow in
                                    NavigationLink(destination: PackingDetailView(flowId: flow.id, homeViewModel: homeViewModel)) {
                                        FlowCardView(flow: flow)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Templates Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Templates")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                                .padding(.horizontal)
                            
                            ForEach(homeViewModel.templates) { template in
                                TemplateCardView(template: template) {
                                    showFlowBuilder = true
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("PackFlow")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFlowBuilder = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appAccent)
                            .font(.title2)
                    }
                }
            }
        }
    }
}

struct FlowCardView: View {
    let flow: PackingFlow
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(flow.title)
                    .font(.headline)
                    .foregroundColor(.appText)
                
                Text("\(Int(flow.progress * 100))% complete")
                    .font(.subheadline)
                    .foregroundColor(.appAccent)
                
                ProgressView(value: flow.progress)
                    .tint(.appAccent)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.appAccent)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct TemplateCardView: View {
    let template: FlowTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    if !template.description.isEmpty {
                        Text(template.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text("\(template.items.count) items")
                        .font(.caption)
                        .foregroundColor(.appAccent)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.appAccent)
                    .font(.title2)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                List {
                    Section {
                        HStack(spacing: 20) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.appAccent)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("PackFlow")
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                
                                Text("Your packing assistant")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section("Achievements") {
                        NavigationLink(destination: AchievementsView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.appAccent)
                                    .frame(width: 24)
                                
                                Text("Achievements")
                                    .foregroundColor(.appText)
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Section("Settings") {
                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate Us",
                            color: .appAccent
                        ) {
                            AppSettings.rateApp()
                        }
                        
                        SettingsRow(
                            icon: "lock.shield.fill",
                            title: "Privacy Policy",
                            color: .appAccent
                        ) {
                            AppSettings.openPrivacyPolicy()
                        }
                        
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            color: .appAccent
                        ) {
                            AppSettings.openTermsOfService()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.appText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}
