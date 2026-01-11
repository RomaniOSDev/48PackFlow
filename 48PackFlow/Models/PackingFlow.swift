//
//  PackingFlow.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation

struct FlowItem: Identifiable, Codable {
    let id: UUID
    var gearItemId: UUID?
    var name: String
    var category: GearCategory
    var isChecked: Bool
    
    init(id: UUID = UUID(), gearItemId: UUID? = nil, name: String, category: GearCategory, isChecked: Bool = false) {
        self.id = id
        self.gearItemId = gearItemId
        self.name = name
        self.category = category
        self.isChecked = isChecked
    }
}

struct PackingFlow: Identifiable, Codable {
    let id: UUID
    var title: String
    var items: [FlowItem]
    var createdAt: Date
    var isTemplate: Bool
    var templateId: UUID?
    var isCustom: Bool
    
    var progress: Double {
        guard !items.isEmpty else { return 0.0 }
        let checkedCount = items.filter { $0.isChecked }.count
        return Double(checkedCount) / Double(items.count)
    }
    
    init(id: UUID = UUID(), title: String, items: [FlowItem] = [], createdAt: Date = Date(), isTemplate: Bool = false, templateId: UUID? = nil, isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.items = items
        self.createdAt = createdAt
        self.isTemplate = isTemplate
        self.templateId = templateId
        self.isCustom = isCustom
    }
}

struct FlowTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var items: [FlowItem]
    
    init(id: UUID = UUID(), name: String, description: String = "", items: [FlowItem] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.items = items
    }
}
