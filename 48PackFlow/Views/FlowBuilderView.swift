//
//  FlowBuilderView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct FlowBuilderView: View {
    @ObservedObject var viewModel: FlowBuilderViewModel
    @ObservedObject var achievementViewModel: AchievementViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Bar
                    if viewModel.currentFlow != nil {
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(Int(viewModel.progress * 100))% Complete")
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(Color.appAccent)
                                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                                        .cornerRadius(4)
                                        .animation(.easeInOut, value: viewModel.progress)
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 16)
                        .background(Color.white)
                    }
                    
                    // Step Content
                    if viewModel.currentStep == 1 {
                        Step1TemplateSelection(viewModel: viewModel)
                    } else {
                        Step2Personalization(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("New Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.reset()
                        dismiss()
                    }
                }
                
                if viewModel.currentStep == 2 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let flow = viewModel.currentFlow {
                                viewModel.saveFlow()
                                
                                // Check achievements
                                achievementViewModel.checkFlowCountAchievements(flowCount: viewModel.homeViewModel.activeFlows.count)
                                achievementViewModel.checkPerfectPackAchievement(flow: flow)
                                if flow.isCustom {
                                    achievementViewModel.checkCustomFlowCreatorAchievement(customFlowCount: viewModel.homeViewModel.getCustomFlowsCount())
                                }
                            }
                            viewModel.reset()
                            dismiss()
                        }
                        .disabled(viewModel.currentFlow == nil)
                    }
                }
            }
        }
    }
}

struct Step1TemplateSelection: View {
    @ObservedObject var viewModel: FlowBuilderViewModel
    @State private var showCustomFlowCreator = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Select a Template")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                    .padding(.top)
                
                // Custom Flow Button
                Button(action: {
                    showCustomFlowCreator = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appAccent)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create Custom Flow")
                                .font(.headline)
                                .foregroundColor(.appText)
                            
                            Text("Build your own packing list from scratch")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.appAccent)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Templates
                ForEach(viewModel.homeViewModel.templates) { template in
                    TemplateSelectionCard(template: template) {
                        viewModel.selectTemplate(template)
                        viewModel.currentStep = 2
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showCustomFlowCreator) {
            CustomFlowCreatorView(viewModel: viewModel)
        }
    }
}

struct TemplateSelectionCard: View {
    let template: FlowTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appAccent)
                }
                
                if !template.description.isEmpty {
                    Text(template.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Label("\(template.items.count) items", systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.appAccent)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Step2Personalization: View {
    @ObservedObject var viewModel: FlowBuilderViewModel
    @State private var showAddGear = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let flow = viewModel.currentFlow {
                    // Items grouped by category
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
                                    FlowItemRow(item: item, viewModel: viewModel)
                                }
                            }
                        }
                    }
                    
                    // Add Item Button
                    Button(action: { showAddGear = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.appAccent)
                            
                            Text("Add Item from Catalog")
                                .foregroundColor(.appAccent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appAccent.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showAddGear) {
            AddGearToFlowView(viewModel: viewModel)
        }
    }
}

struct FlowItemRow: View {
    let item: FlowItem
    @ObservedObject var viewModel: FlowBuilderViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation {
                    viewModel.toggleItem(item)
                }
            }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isChecked ? .appAccent : .gray)
            }
            
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
}

struct AddGearToFlowView: View {
    @ObservedObject var viewModel: FlowBuilderViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var gearCatalogViewModel = GearCatalogViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gearCatalogViewModel.gearItems) { gearItem in
                    Button(action: {
                        viewModel.addGearItemToFlow(gearItem)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: gearItem.category.icon)
                                .foregroundColor(.appAccent)
                                .frame(width: 30)
                            
                            Text(gearItem.name)
                                .foregroundColor(.appText)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Add Gear")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}


