//
//  AchievementViewModel.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation
import Combine

class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var recentlyUnlocked: [Achievement] = []
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievements"
    private let lastActiveDateKey = "lastActiveDate"
    private let consecutiveDaysKey = "consecutiveDays"
    
    init() {
        loadAchievements()
        initializeAchievementsIfNeeded()
    }
    
    func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let achievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = achievements
        }
    }
    
    func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            userDefaults.set(data, forKey: achievementsKey)
        }
    }
    
    private func initializeAchievementsIfNeeded() {
        if achievements.isEmpty {
            achievements = AchievementType.allCases.map { Achievement(type: $0) }
            saveAchievements()
        }
    }
    
    func checkAchievement(_ type: AchievementType) {
        guard let index = achievements.firstIndex(where: { $0.type == type }),
              !achievements[index].isUnlocked else { return }
        
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        
        let achievementId = achievements[index].id
        recentlyUnlocked.append(achievements[index])
        saveAchievements()
        
        // Remove from recently unlocked after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.recentlyUnlocked.removeAll { $0.id == achievementId }
        }
    }
    
    func checkFlowCountAchievements(flowCount: Int) {
        if flowCount >= 1 {
            checkAchievement(.firstFlow)
        }
        if flowCount >= 10 {
            checkAchievement(.tenFlows)
        }
    }
    
    func checkPerfectPackAchievement(flow: PackingFlow) {
        if flow.progress >= 1.0 {
            checkAchievement(.perfectPack)
        }
    }
    
    func checkCatalogMasterAchievement(itemCount: Int) {
        if itemCount >= 20 {
            checkAchievement(.catalogMaster)
        }
    }
    
    func checkScannerProAchievement(scanCount: Int) {
        if scanCount >= 5 {
            checkAchievement(.scannerPro)
        }
    }
    
    func checkCustomFlowCreatorAchievement(customFlowCount: Int) {
        if customFlowCount >= 5 {
            checkAchievement(.customFlowCreator)
        }
    }
    
    func updateDailyActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastActiveDate = userDefaults.object(forKey: lastActiveDateKey) as? Date
        
        if let lastDate = lastActiveDate {
            let lastActiveDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                let currentConsecutive = userDefaults.integer(forKey: consecutiveDaysKey)
                userDefaults.set(currentConsecutive + 1, forKey: consecutiveDaysKey)
            } else if daysDifference > 1 {
                // Reset consecutive days
                userDefaults.set(1, forKey: consecutiveDaysKey)
            }
            // If daysDifference == 0, same day, don't update
        } else {
            // First time
            userDefaults.set(1, forKey: consecutiveDaysKey)
        }
        
        userDefaults.set(Date(), forKey: lastActiveDateKey)
        
        let consecutiveDays = userDefaults.integer(forKey: consecutiveDaysKey)
        if consecutiveDays >= 7 {
            checkAchievement(.weeklyActive)
        }
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
}
