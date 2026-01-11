//
//  CustomFlowCreatorView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct CustomFlowCreatorView: View {
    @ObservedObject var viewModel: FlowBuilderViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var flowTitle = ""
    @State private var showAddItem = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if viewModel.currentFlow == nil {
                        // Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Flow Name")
                                .font(.headline)
                                .foregroundColor(.appText)
                            
                            TextField("Enter flow name", text: $flowTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        
                        Button(action: {
                            if !flowTitle.isEmpty {
                                viewModel.createCustomFlow(title: flowTitle)
                            }
                        }) {
                            Text("Create Flow")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(flowTitle.isEmpty ? Color.gray : Color.appAccent)
                                .cornerRadius(10)
                        }
                        .disabled(flowTitle.isEmpty)
                        .padding(.horizontal)
                    } else {
                        // Flow Items Management
                        ScrollView {
                            VStack(spacing: 16) {
                                if let flow = viewModel.currentFlow {
                                    Text(flow.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appText)
                                        .padding(.top)
                                    
                                    if flow.items.isEmpty {
                                        VStack(spacing: 16) {
                                            Image(systemName: "bag.fill")
                                                .font(.system(size: 60))
                                                .foregroundColor(.gray.opacity(0.5))
                                            
                                            Text("No items yet")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                            
                                            Text("Add items to your custom flow")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 40)
                                    } else {
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
                                                        HStack {
                                                            Text(item.name)
                                                                .foregroundColor(.appText)
                                                            
                                                            Spacer()
                                                            
                                                            Button(action: {
                                                                viewModel.removeItem(item)
                                                            }) {
                                                                Image(systemName: "trash")
                                                                    .foregroundColor(.red)
                                                            }
                                                        }
                                                        .padding()
                                                        .background(Color.white)
                                                        .cornerRadius(10)
                                                        .padding(.horizontal)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            showAddItem = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.appAccent)
                                
                                Text("Add Item")
                                    .foregroundColor(.appAccent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appAccent.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Custom Flow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.reset()
                        dismiss()
                    }
                }
                
                if viewModel.currentFlow != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if viewModel.currentFlow != nil && !viewModel.currentFlow!.items.isEmpty {
                                viewModel.currentStep = 2
                                dismiss()
                            }
                        }
                        .disabled(viewModel.currentFlow?.items.isEmpty ?? true)
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddCustomItemView(viewModel: viewModel)
            }
        }
    }
}

struct AddCustomItemView: View {
    @ObservedObject var viewModel: FlowBuilderViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var itemName = ""
    @State private var selectedCategory: GearCategory = .other
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $itemName)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GearCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !itemName.isEmpty {
                            viewModel.addCustomItem(name: itemName, category: selectedCategory)
                            dismiss()
                        }
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CustomFlowCreatorView(viewModel: FlowBuilderViewModel(homeViewModel: HomeViewModel(), gearCatalogViewModel: GearCatalogViewModel()))
}
