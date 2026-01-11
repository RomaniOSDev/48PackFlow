//
//  Achievement.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation

enum AchievementType: String, Codable, CaseIterable {
    case firstFlow = "first_flow"
    case tenFlows = "ten_flows"
    case perfectPack = "perfect_pack"
    case catalogMaster = "catalog_master"
    case scannerPro = "scanner_pro"
    case customFlowCreator = "custom_flow_creator"
    case weeklyActive = "weekly_active"
    
    var title: String {
        switch self {
        case .firstFlow: return "First Steps"
        case .tenFlows: return "Packing Pro"
        case .perfectPack: return "Perfect Pack"
        case .catalogMaster: return "Catalog Master"
        case .scannerPro: return "Scanner Pro"
        case .customFlowCreator: return "Custom Creator"
        case .weeklyActive: return "Weekly Warrior"
        }
    }
    
    var description: String {
        switch self {
        case .firstFlow: return "Create your first packing flow"
        case .tenFlows: return "Create 10 packing flows"
        case .perfectPack: return "Complete a flow with 100% items"
        case .catalogMaster: return "Add 20 items to your catalog"
        case .scannerPro: return "Scan 5 items using barcode scanner"
        case .customFlowCreator: return "Create 5 custom flows"
        case .weeklyActive: return "Use the app 7 days in a row"
        }
    }
    
    var icon: String {
        switch self {
        case .firstFlow: return "star.fill"
        case .tenFlows: return "star.circle.fill"
        case .perfectPack: return "checkmark.seal.fill"
        case .catalogMaster: return "square.grid.3x3.fill"
        case .scannerPro: return "barcode.viewfinder"
        case .customFlowCreator: return "pencil.circle.fill"
        case .weeklyActive: return "calendar"
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(id: UUID = UUID(), type: AchievementType, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id
        self.type = type
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}
