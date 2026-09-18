import Foundation

enum LineupStore {
    static let maps: [Map] = [
        mirageMap
    ]

    static let mirageMap: Map = loadMirageMap()

    private static func loadMirageMap() -> Map {
        guard let url = Bundle.main.url(forResource: "lineups_mirage", withExtension: "json") else {
            return fallbackMirageMap
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Map.self, from: data)
        } catch {
            return fallbackMirageMap
        }
    }

    private static let fallbackMirageMap = Map(
        id: "mirage",
        name: LocalizedText(en: "Mirage", zhHans: "Mirage"),
        imageName: "mirage_map",
        lineupGroups: []
    )
}
