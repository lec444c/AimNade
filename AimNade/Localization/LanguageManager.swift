import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case zhHans
    case en

    var id: String {
        rawValue
    }
}

final class LanguageManager: ObservableObject {
    private let storageKey = "selectedLanguage"

    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: storageKey)
        }
    }

    init() {
        let savedValue = UserDefaults.standard.string(forKey: storageKey)
        selectedLanguage = AppLanguage(rawValue: savedValue ?? "") ?? .system
    }

    var contentLanguage: AppLanguage {
        switch selectedLanguage {
        case .system:
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            return preferredLanguage.hasPrefix("zh") ? .zhHans : .en
        case .zhHans:
            return .zhHans
        case .en:
            return .en
        }
    }
}
