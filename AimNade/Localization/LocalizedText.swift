import Foundation

struct LocalizedText: Hashable, Codable {
    let en: String
    let zhHans: String

    func value(for languageManager: LanguageManager) -> String {
        switch languageManager.contentLanguage {
        case .system, .en:
            return en
        case .zhHans:
            return zhHans
        }
    }
}
