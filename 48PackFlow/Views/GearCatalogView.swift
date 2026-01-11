//
//  GearCatalogView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI

struct GearCatalogView: View {
    @ObservedObject var viewModel: GearCatalogViewModel
    @StateObject private var achievementViewModel = AchievementViewModel()
    @State private var showAddItem = false
    @State private var showScanner = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search gear...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: viewModel.selectedCategory == nil,
                                action: { viewModel.selectedCategory = nil }
                            )
                            
                            ForEach(GearCategory.allCases) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    isSelected: viewModel.selectedCategory == category,
                                    action: { viewModel.selectedCategory = category }
                                )
                            }
                            
                            Toggle("Packed Only", isOn: $viewModel.showPackedOnly)
                                .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                                .padding(.horizontal, 8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    
                    // Items List
                    if viewModel.filteredItems.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No items found")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredItems) { item in
                                    GearItemCardView(item: item, viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Gear Catalog")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showScanner = true }) {
                        Image(systemName: "barcode.viewfinder")
                            .foregroundColor(.appAccent)
                            .font(.title2)
                    }
                    
                    Button(action: { showAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appAccent)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddGearItemView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showScanner) {
                BarcodeScannerView(gearCatalogViewModel: viewModel, achievementViewModel: achievementViewModel)
            }
            .onAppear {
                achievementViewModel.checkCatalogMasterAchievement(itemCount: viewModel.itemCount)
            }
            .onChange(of: viewModel.itemCount) { newCount in
                achievementViewModel.checkCatalogMasterAchievement(itemCount: newCount)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .appText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appAccent : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct GearItemCardView: View {
    let item: GearItem
    @ObservedObject var viewModel: GearCatalogViewModel
    @State private var showEdit = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: item.category.icon)
                .font(.title2)
                .foregroundColor(.appAccent)
                .frame(width: 50, height: 50)
                .background(Color.appAccent.opacity(0.1))
                .cornerRadius(10)
            
            // Item Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.appText)
                
                Text(item.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Packed Status
            Button(action: {
                viewModel.togglePackedStatus(for: item)
            }) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isPacked ? .appAccent : .gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.deleteGearItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                showEdit = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.appAccent)
        }
        .sheet(isPresented: $showEdit) {
            EditGearItemView(item: item, viewModel: viewModel)
        }
    }
}

struct AddGearItemView: View {
    @ObservedObject var viewModel: GearCatalogViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedCategory: GearCategory = .other
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $name)
                    
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
                        let item = GearItem(name: name, category: selectedCategory)
                        viewModel.addGearItem(item)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct EditGearItemView: View {
    let item: GearItem
    @ObservedObject var viewModel: GearCatalogViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var selectedCategory: GearCategory
    
    init(item: GearItem, viewModel: GearCatalogViewModel) {
        self.item = item
        self.viewModel = viewModel
        _name = State(initialValue: item.name)
        _selectedCategory = State(initialValue: item.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $name)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GearCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedItem = item
                        updatedItem.name = name
                        updatedItem.category = selectedCategory
                        viewModel.updateGearItem(updatedItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    GearCatalogView(viewModel: GearCatalogViewModel())
}
