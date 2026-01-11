//
//  HomeViewModel.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var activeFlows: [PackingFlow] = []
    @Published var templates: [FlowTemplate] = []
    
    private let userDefaults = UserDefaults.standard
    private let activeFlowsKey = "activeFlows"
    private let templatesKey = "templates"
    
    var customFlowsCount: Int {
        activeFlows.filter { $0.isCustom }.count
    }
    
    init() {
        loadData()
        createDefaultTemplatesIfNeeded()
    }
    
    func loadData() {
        if let data = userDefaults.data(forKey: activeFlowsKey),
           let flows = try? JSONDecoder().decode([PackingFlow].self, from: data) {
            activeFlows = flows
        }
        
        if let data = userDefaults.data(forKey: templatesKey),
           let templates = try? JSONDecoder().decode([FlowTemplate].self, from: data) {
            self.templates = templates
        }
    }
    
    func saveActiveFlows() {
        if let data = try? JSONEncoder().encode(activeFlows) {
            userDefaults.set(data, forKey: activeFlowsKey)
        }
    }
    
    func saveTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            userDefaults.set(data, forKey: templatesKey)
        }
    }
    
    func createFlow(from template: FlowTemplate) -> PackingFlow {
        let items = template.items.map { FlowItem(
            id: UUID(),
            gearItemId: $0.gearItemId,
            name: $0.name,
            category: $0.category,
            isChecked: false
        )}
        return PackingFlow(
            title: template.name,
            items: items,
            isTemplate: false,
            templateId: template.id
        )
    }
    
    func addActiveFlow(_ flow: PackingFlow) {
        activeFlows.append(flow)
        saveActiveFlows()
    }
    
    func getCustomFlowsCount() -> Int {
        activeFlows.filter { $0.isCustom }.count
    }
    
    func deleteFlow(_ flow: PackingFlow) {
        activeFlows.removeAll { $0.id == flow.id }
        saveActiveFlows()
    }
    
    private func createDefaultTemplatesIfNeeded() {
        guard templates.isEmpty else { return }
        
        templates = [
            FlowTemplate(
                name: "5K Run",
                description: "Essential items for a 5K run",
                items: [
                    FlowItem(name: "Running Shoes", category: .footwear),
                    FlowItem(name: "Running Shorts", category: .clothing),
                    FlowItem(name: "T-Shirt", category: .clothing),
                    FlowItem(name: "Water Bottle", category: .accessories)
                ]
            ),
            FlowTemplate(
                name: "Gym Workout",
                description: "Gym training essentials",
                items: [
                    FlowItem(name: "Gym Shoes", category: .footwear),
                    FlowItem(name: "Workout Clothes", category: .clothing),
                    FlowItem(name: "Towel", category: .accessories),
                    FlowItem(name: "Water Bottle", category: .accessories),
                    FlowItem(name: "Gym Bag", category: .accessories)
                ]
            ),
            FlowTemplate(
                name: "Weekend Bike Trip",
                description: "Equipment for a weekend cycling trip",
                items: [
                    FlowItem(name: "Cycling Shoes", category: .footwear),
                    FlowItem(name: "Cycling Jersey", category: .clothing),
                    FlowItem(name: "Helmet", category: .equipment),
                    FlowItem(name: "Water Bottle", category: .accessories),
                    FlowItem(name: "Repair Kit", category: .equipment),
                    FlowItem(name: "Energy Bars", category: .nutrition)
                ]
            )
        ]
        saveTemplates()
    }
}
