import SwiftUI

final class DeveloperSettings: ObservableObject {
    private let storageKey = "developerModeEnabled"

    @Published var isDeveloperModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isDeveloperModeEnabled, forKey: storageKey)
        }
    }

    init() {
        isDeveloperModeEnabled = UserDefaults.standard.bool(forKey: storageKey)
    }
}
