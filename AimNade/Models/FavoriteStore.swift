import Foundation

final class FavoriteStore: ObservableObject {
    private let groupStorageKey = "favoriteGroupIDs"
    private let variantStorageKey = "favoriteVariantIDs"

    @Published private(set) var groupIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(groupIDs), forKey: groupStorageKey)
        }
    }

    @Published private(set) var variantIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(variantIDs), forKey: variantStorageKey)
        }
    }

    init() {
        groupIDs = Set(UserDefaults.standard.stringArray(forKey: groupStorageKey) ?? [])
        variantIDs = Set(UserDefaults.standard.stringArray(forKey: variantStorageKey) ?? [])
    }

    func isFavoriteGroup(_ group: LineupGroup) -> Bool {
        groupIDs.contains(group.id)
    }

    func isFavoriteVariant(_ variant: LineupVariant) -> Bool {
        variantIDs.contains(variant.id)
    }

    func toggleGroup(_ group: LineupGroup) {
        if groupIDs.contains(group.id) {
            groupIDs.remove(group.id)
        } else {
            groupIDs.insert(group.id)
        }
    }

    func toggleVariant(_ variant: LineupVariant) {
        if variantIDs.contains(variant.id) {
            variantIDs.remove(variant.id)
        } else {
            variantIDs.insert(variant.id)
        }
    }

    func favoriteGroups(in map: Map) -> [LineupGroup] {
        map.lineupGroups.filter { groupIDs.contains($0.id) }
    }

    func favoriteVariants(in map: Map) -> [FavoriteVariant] {
        map.lineupGroups.flatMap { group in
            group.variants
                .filter { variantIDs.contains($0.id) }
                .map { FavoriteVariant(group: group, variant: $0) }
        }
    }
}

struct FavoriteVariant: Identifiable {
    let group: LineupGroup
    let variant: LineupVariant

    var id: String {
        variant.id
    }
}
