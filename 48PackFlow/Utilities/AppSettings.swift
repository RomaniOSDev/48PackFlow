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
        if let url = URL(string: "https://example.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    static func openTermsOfService() {
        if let url = URL(string: "https://example.com/terms-of-service") {
            UIApplication.shared.open(url)
        }
    }
    
    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
