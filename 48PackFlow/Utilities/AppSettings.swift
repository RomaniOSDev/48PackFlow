//
//  AppSettings.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation
import UIKit
import StoreKit

struct AppSettings {
    static func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/bebd3374-e003-4151-872a-c8f2264c4d7c") {
            UIApplication.shared.open(url)
        }
    }
    
    static func openTermsOfService() {
        if let url = URL(string: "https://www.termsfeed.com/live/16d79553-f3a2-4b05-9d05-e2314be68df1") {
            UIApplication.shared.open(url)
        }
    }
    
    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
