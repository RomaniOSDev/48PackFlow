//
//  GearCatalogViewModel.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation
import Combine

class GearCatalogViewModel: ObservableObject {
    @Published var gearItems: [GearItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: GearCategory?
    @Published var showPackedOnly: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let gearItemsKey = "gearItems"
    
    var filteredItems: [GearItem] {
        var items = gearItems
        
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if showPackedOnly {
            items = items.filter { $0.isPacked }
        }
        
        return items.sorted { $0.name < $1.name }
    }
    
    init() {
        loadGearItems()
        createDefaultItemsIfNeeded()
    }
    
    func loadGearItems() {
        if let data = userDefaults.data(forKey: gearItemsKey),
           let items = try? JSONDecoder().decode([GearItem].self, from: data) {
            gearItems = items
        }
    }
    
    func saveGearItems() {
        if let data = try? JSONEncoder().encode(gearItems) {
            userDefaults.set(data, forKey: gearItemsKey)
        }
    }
    
    func addGearItem(_ item: GearItem) {
        gearItems.append(item)
        saveGearItems()
    }
    
    var itemCount: Int {
        gearItems.count
    }
    
    func updateGearItem(_ item: GearItem) {
        if let index = gearItems.firstIndex(where: { $0.id == item.id }) {
            gearItems[index] = item
            saveGearItems()
        }
    }
    
    func deleteGearItem(_ item: GearItem) {
        gearItems.removeAll { $0.id == item.id }
        saveGearItems()
    }
    
    func togglePackedStatus(for item: GearItem) {
        var updatedItem = item
        updatedItem.isPacked.toggle()
        updatedItem.lastUsedDate = Date()
        updateGearItem(updatedItem)
    }
    
    private func createDefaultItemsIfNeeded() {
        guard gearItems.isEmpty else { return }
        
        gearItems = [
            GearItem(name: "Nike Running Shoes", category: .footwear),
            GearItem(name: "Adidas Workout Shorts", category: .clothing),
            GearItem(name: "Under Armour T-Shirt", category: .clothing),
            GearItem(name: "Gym Bag", category: .accessories),
            GearItem(name: "Water Bottle", category: .accessories),
            GearItem(name: "Fitness Tracker", category: .electronics),
            GearItem(name: "Yoga Mat", category: .equipment)
        ]
        saveGearItems()
    }
}
