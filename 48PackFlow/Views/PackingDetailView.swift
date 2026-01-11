//
//  PackingDetailView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct PackingDetailView: View {
    let flowId: UUID
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var achievementViewModel = AchievementViewModel()
    @State private var viewMode: ViewMode = .list
    @State private var showShareSheet = false
    
    enum ViewMode {
        case list
        case grid
    }
    
    private var flow: PackingFlow? {
        homeViewModel.activeFlows.first { $0.id == flowId }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if let flow = flow {
                VStack(spacing: 0) {
                    // Header with Progress
                    VStack(spacing: 12) {
                        Text(flow.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Text("\(Int(flow.progress * 100))% Complete")
                            .font(.headline)
                            .foregroundColor(.appAccent)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 10)
                                    .cornerRadius(5)
                                
                                Rectangle()
                                    .fill(Color.appAccent)
                                    .frame(width: geometry.size.width * flow.progress, height: 10)
                                    .cornerRadius(5)
                                    .animation(.easeInOut, value: flow.progress)
                            }
                        }
                        .frame(height: 10)
                        
                        // View Mode Toggle
                        Picker("View Mode", selection: $viewMode) {
                            Text("List").tag(ViewMode.list)
                            Text("Grid").tag(ViewMode.grid)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Content
                    if viewMode == .list {
                        ListView(flowId: flowId, homeViewModel: homeViewModel, achievementViewModel: achievementViewModel)
                    } else {
                        GridView(flowId: flowId, homeViewModel: homeViewModel, achievementViewModel: achievementViewModel)
                    }
                }
            } else {
                Text("Flow not found")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Packing Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.appAccent)
                }
                .disabled(flow == nil)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let flow = flow {
                ShareSheet(items: generateShareText(for: flow))
            }
        }
    }
    
    private func generateShareText(for flow: PackingFlow) -> String {
        var text = "\(flow.title)\n\n"
        text += "Packing List:\n"
        
        for category in GearCategory.allCases {
            let categoryItems = flow.items.filter { $0.category == category }
            if !categoryItems.isEmpty {
                text += "\n\(category.rawValue):\n"
                for item in categoryItems {
                    let status = item.isChecked ? "✓" : "○"
                    text += "\(status) \(item.name)\n"
                }
            }
        }
        
        text += "\nProgress: \(Int(flow.progress * 100))%"
        return text
    }
}

struct ListView: View {
    let flowId: UUID
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var achievementViewModel: AchievementViewModel
    
    private var flow: PackingFlow? {
        homeViewModel.activeFlows.first { $0.id == flowId }
    }
    
    var body: some View {
        ScrollView {
            if let flow = flow {
                VStack(spacing: 16) {
                    ForEach(GearCategory.allCases, id: \.self) { category in
                        let categoryItems = flow.items.filter { $0.category == category }
                        
                        if !categoryItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(.appAccent)
                                    
                                    Text(category.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.appText)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                ForEach(categoryItems) { item in
                                    Button(action: {
                                        toggleItem(item)
                                    }) {
                                        HStack(spacing: 16) {
                                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(item.isChecked ? .appAccent : .gray)
                                                .font(.title3)
                                            
                                            Text(item.name)
                                                .font(.body)
                                                .foregroundColor(item.isChecked ? .gray : .appText)
                                                .strikethrough(item.isChecked)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
    
    private func toggleItem(_ item: FlowItem) {
        guard let flow = flow,
              let flowIndex = homeViewModel.activeFlows.firstIndex(where: { $0.id == flowId }),
              let itemIndex = homeViewModel.activeFlows[flowIndex].items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        homeViewModel.activeFlows[flowIndex].items[itemIndex].isChecked.toggle()
        homeViewModel.saveActiveFlows()
        
        // Check perfect pack achievement
        let updatedFlow = homeViewModel.activeFlows[flowIndex]
        achievementViewModel.checkPerfectPackAchievement(flow: updatedFlow)
    }
}

struct GridView: View {
    let flowId: UUID
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var achievementViewModel: AchievementViewModel
    
    private var flow: PackingFlow? {
        homeViewModel.activeFlows.first { $0.id == flowId }
    }
    
    var body: some View {
        ScrollView {
            if let flow = flow {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(flow.items) { item in
                        Button(action: {
                            toggleItem(item)
                        }) {
                            GridItemCard(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
    
    private func toggleItem(_ item: FlowItem) {
        guard let flow = flow,
              let flowIndex = homeViewModel.activeFlows.firstIndex(where: { $0.id == flowId }),
              let itemIndex = homeViewModel.activeFlows[flowIndex].items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        homeViewModel.activeFlows[flowIndex].items[itemIndex].isChecked.toggle()
        homeViewModel.saveActiveFlows()
        
        // Check perfect pack achievement
        let updatedFlow = homeViewModel.activeFlows[flowIndex]
        achievementViewModel.checkPerfectPackAchievement(flow: updatedFlow)
    }
}

struct GridItemCard: View {
    let item: FlowItem
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.system(size: 40))
                .foregroundColor(item.isChecked ? .gray : .appAccent)
            
            Text(item.name)
                .font(.caption)
                .foregroundColor(item.isChecked ? .gray : .appText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if item.isChecked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.appAccent)
                    .font(.title3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(item.isChecked ? 0.6 : 1.0)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    init(items: String) {
        self.items = [items]
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let homeViewModel = HomeViewModel()
    let testFlow = PackingFlow(
        title: "5K Run",
        items: [
            FlowItem(name: "Running Shoes", category: .footwear, isChecked: true),
            FlowItem(name: "Running Shorts", category: .clothing, isChecked: false)
        ]
    )
    homeViewModel.addActiveFlow(testFlow)
    
    return NavigationView {
        PackingDetailView(
            flowId: testFlow.id,
            homeViewModel: homeViewModel
        )
    }
}
