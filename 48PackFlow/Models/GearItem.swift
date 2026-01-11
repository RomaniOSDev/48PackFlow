//
//  GearItem.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation

enum GearCategory: String, CaseIterable, Identifiable, Codable {
    case footwear = "Footwear"
    case clothing = "Clothing"
    case accessories = "Accessories"
    case electronics = "Electronics"
    case equipment = "Equipment"
    case nutrition = "Nutrition"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .footwear: return "shoe.fill"
        case .clothing: return "tshirt.fill"
        case .accessories: return "bag.fill"
        case .electronics: return "iphone"
        case .equipment: return "figure.run"
        case .nutrition: return "drop.fill"
        case .other: return "square.fill"
        }
    }
}

struct GearItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: GearCategory
    var imageURL: String?
    var lastUsedDate: Date?
    var isPacked: Bool
    
    init(id: UUID = UUID(), name: String, category: GearCategory, imageURL: String? = nil, lastUsedDate: Date? = nil, isPacked: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.imageURL = imageURL
        self.lastUsedDate = lastUsedDate
        self.isPacked = isPacked
    }
}
