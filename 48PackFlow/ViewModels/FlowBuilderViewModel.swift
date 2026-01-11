//
//  FlowBuilderViewModel.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation
import Combine

class FlowBuilderViewModel: ObservableObject {
    @Published var currentFlow: PackingFlow?
    @Published var selectedTemplate: FlowTemplate?
    @Published var currentStep: Int = 1
    @Published var availableGearItems: [GearItem] = []
    
    let homeViewModel: HomeViewModel
    private let gearCatalogViewModel: GearCatalogViewModel
    
    var progress: Double {
        currentFlow?.progress ?? 0.0
    }
    
    var canProceedToStep2: Bool {
        selectedTemplate != nil
    }
    
    init(homeViewModel: HomeViewModel, gearCatalogViewModel: GearCatalogViewModel) {
        self.homeViewModel = homeViewModel
        self.gearCatalogViewModel = gearCatalogViewModel
        loadAvailableGearItems()
    }
    
    func loadAvailableGearItems() {
        availableGearItems = gearCatalogViewModel.gearItems
    }
    
    func selectTemplate(_ template: FlowTemplate) {
        selectedTemplate = template
        let flow = homeViewModel.createFlow(from: template)
        currentFlow = flow
    }
    
    func createCustomFlow(title: String) {
        selectedTemplate = nil
        currentFlow = PackingFlow(title: title, items: [], isTemplate: false, isCustom: true)
    }
    
    func addCustomItem(name: String, category: GearCategory) {
        guard var flow = currentFlow else { return }
        let flowItem = FlowItem(
            name: name,
            category: category,
            isChecked: false
        )
        flow.items.append(flowItem)
        currentFlow = flow
    }
    
    func toggleItem(_ item: FlowItem) {
        guard var flow = currentFlow else { return }
        if let index = flow.items.firstIndex(where: { $0.id == item.id }) {
            flow.items[index].isChecked.toggle()
            currentFlow = flow
        }
    }
    
    func addGearItemToFlow(_ gearItem: GearItem) {
        guard var flow = currentFlow else { return }
        let flowItem = FlowItem(
            gearItemId: gearItem.id,
            name: gearItem.name,
            category: gearItem.category,
            isChecked: false
        )
        flow.items.append(flowItem)
        currentFlow = flow
    }
    
    func removeItem(_ item: FlowItem) {
        guard var flow = currentFlow else { return }
        flow.items.removeAll { $0.id == item.id }
        currentFlow = flow
    }
    
    func saveFlow() {
        guard let flow = currentFlow else { return }
        homeViewModel.addActiveFlow(flow)
    }
    
    func reset() {
        currentFlow = nil
        selectedTemplate = nil
        currentStep = 1
    }
}
