import SwiftUI
import UIKit

struct TacticalMapView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var developerSettings: DeveloperSettings

    @State private var selectedGroup: LineupGroup?
    @State private var selectedGroupCluster: LineupCluster?
    @State private var selectedAreaFilter: MapAreaFilter = .featured
    @State private var selectedTypeFilter: MapUtilityTypeFilter = .all
    @State private var currentZoomScale: CGFloat = 1.0
    @State private var showDeveloperTargets = true
    @State private var showDeveloperVariantStarts = true
    @State private var showDeveloperLines = true
    @State private var editedCoordinates: [MapPointKey: CGPoint] = [:]
    @State private var activeCoordinate: EditedLineupCoordinate?
    @State private var lastEditedCoordinate: EditedLineupCoordinate?
    @State private var copyStatusMessage: String?

    let map: Map

    private var groups: [LineupGroup] {
        map.lineupGroups
    }

    private var filteredGroups: [LineupGroup] {
        groups.filter { group in
            selectedAreaFilter.matches(group)
                && selectedTypeFilter.matches(group)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = max(geometry.size.width - AppTheme.pagePadding * 2, 1)
            let reservedHeight: CGFloat = developerSettings.isDeveloperModeEnabled ? 420 : 176
            let availableHeight = max(geometry.size.height - reservedHeight, 1)
            let mapContainerSize = CGSize(width: availableWidth, height: availableHeight)
            let mapImageSize = UIImage(named: map.imageName)?.size ?? CGSize(width: 1, height: 1)

            VStack(spacing: 12) {
                MapFilterBar(
                    selectedAreaFilter: $selectedAreaFilter,
                    selectedTypeFilter: $selectedTypeFilter
                )
                .environmentObject(languageManager)

                if developerSettings.isDeveloperModeEnabled {
                    DeveloperDisplayControls(
                        showTargets: $showDeveloperTargets,
                        showVariantStarts: $showDeveloperVariantStarts,
                        showLines: $showDeveloperLines
                    )
                    .environmentObject(languageManager)
                }

                ZoomableScrollView(
                    minScale: 1.0,
                    maxScale: 4.0,
                    doubleTapScale: 2.5,
                    isPointEditingEnabled: developerSettings.isDeveloperModeEnabled,
                    zoomScale: $currentZoomScale
                ) {
                    MapCanvas(
                        containerSize: mapContainerSize,
                        mapImageName: map.imageName,
                        imageSize: mapImageSize,
                        groups: filteredGroups,
                        editedCoordinates: editedCoordinates,
                        developerModeEnabled: developerSettings.isDeveloperModeEnabled,
                        showDeveloperTargets: showDeveloperTargets,
                        showDeveloperVariantStarts: showDeveloperVariantStarts,
                        showDeveloperLines: showDeveloperLines,
                        zoomScale: currentZoomScale,
                        onSelect: { group in
                            selectedGroup = group
                        },
                        onSelectCluster: { cluster in
                            selectedGroupCluster = cluster
                        },
                        onCoordinateChanged: { group, variant, kind, coordinate in
                            updateEditedCoordinate(
                                group: group,
                                variant: variant,
                                kind: kind,
                                coordinate: coordinate,
                                isFinished: false
                            )
                        },
                        onCoordinateEnded: { group, variant, kind, coordinate in
                            updateEditedCoordinate(
                                group: group,
                                variant: variant,
                                kind: kind,
                                coordinate: coordinate,
                                isFinished: true
                            )
                        }
                    )
                    .environmentObject(languageManager)
                }
                .frame(width: mapContainerSize.width, height: mapContainerSize.height)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .stroke(AppTheme.secondaryText.opacity(0.35), lineWidth: 1)
                }

                Text(mapHintText)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.secondaryText)

                if developerSettings.isDeveloperModeEnabled {
                    DeveloperCoordinatePanel(
                        coordinate: activeCoordinate ?? lastEditedCoordinate,
                        statusMessage: copyStatusMessage,
                        onCopyCoordinates: copyCurrentCoordinates,
                        onCopyJSON: copyJSONCoordinates
                    )
                    .environmentObject(languageManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(AppTheme.pagePadding)
        }
        .background(AppTheme.background)
        .navigationTitle(map.name.value(for: languageManager))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedGroup) { group in
            LineupGroupDetailView(group: group)
        }
        .sheet(item: $selectedGroupCluster) { cluster in
            ClusterLineupSheet(cluster: cluster) { group in
                selectedGroupCluster = nil
                DispatchQueue.main.async {
                    selectedGroup = group
                }
            }
            .environmentObject(languageManager)
        }
    }

    private var mapHintText: String {
        if developerSettings.isDeveloperModeEnabled {
            return L10n.text(.developerMapHint, for: languageManager)
        }

        return L10n.text(.tapUtilityHint, for: languageManager)
    }

    private func updateEditedCoordinate(
        group: LineupGroup,
        variant: LineupVariant?,
        kind: MapPointKind,
        coordinate: CGPoint,
        isFinished: Bool
    ) {
        let displayName = variant?.name.value(for: languageManager) ?? group.targetName.value(for: languageManager)
        let editedCoordinate = EditedLineupCoordinate(
            id: MapPointKey(entityID: kind.entityID(group: group, variant: variant), kind: kind),
            displayName: displayName,
            kind: kind,
            mapX: Double(coordinate.x),
            mapY: Double(coordinate.y)
        )

        editedCoordinates[editedCoordinate.id] = coordinate
        copyStatusMessage = nil

        if isFinished {
            activeCoordinate = nil
            lastEditedCoordinate = editedCoordinate
        } else {
            activeCoordinate = editedCoordinate
        }
    }

    private func copyCurrentCoordinates() {
        guard let coordinate = activeCoordinate ?? lastEditedCoordinate else {
            return
        }

        UIPasteboard.general.string = coordinate.coordinateText
        copyStatusMessage = L10n.text(.coordinatesCopied, for: languageManager)
    }

    private func copyJSONCoordinates() {
        let jsonItems = groups.map { group in
            let targetCoordinate = groupTargetCoordinate(for: group)
            let variants = group.variants.map { variant in
                let startCoordinate = variantStartCoordinate(for: group, variant: variant)
                let variantTargetCoordinate = variantTargetCoordinate(for: group, variant: variant)

                return [
                    "id": variant.id,
                    "startMapX": roundedCoordinate(Double(startCoordinate.x)),
                    "startMapY": roundedCoordinate(Double(startCoordinate.y)),
                    "targetMapX": roundedCoordinate(Double(variantTargetCoordinate.x)),
                    "targetMapY": roundedCoordinate(Double(variantTargetCoordinate.y))
                ] as [String: Any]
            }

            return [
                "id": group.id,
                "targetMapX": roundedCoordinate(Double(targetCoordinate.x)),
                "targetMapY": roundedCoordinate(Double(targetCoordinate.y)),
                "variants": variants
            ] as [String: Any]
        }

        if let data = try? JSONSerialization.data(
            withJSONObject: jsonItems,
            options: [.prettyPrinted, .sortedKeys]
        ),
           let jsonString = String(data: data, encoding: .utf8) {
            UIPasteboard.general.string = jsonString
            copyStatusMessage = L10n.text(.jsonCopied, for: languageManager)
        }
    }

    private func groupTargetCoordinate(for group: LineupGroup) -> CGPoint {
        let key = MapPointKey(entityID: group.id, kind: .groupTarget)

        if let editedCoordinate = editedCoordinates[key] {
            return editedCoordinate
        }

        return group.targetCoordinate
    }

    private func variantStartCoordinate(for group: LineupGroup, variant: LineupVariant) -> CGPoint {
        let key = MapPointKey(entityID: variant.id, kind: .variantStart)

        if let editedCoordinate = editedCoordinates[key] {
            return editedCoordinate
        }

        return variant.startCoordinate
    }

    private func variantTargetCoordinate(for group: LineupGroup, variant: LineupVariant) -> CGPoint {
        let key = MapPointKey(entityID: group.id, kind: .groupTarget)

        if let editedCoordinate = editedCoordinates[key] {
            return editedCoordinate
        }

        return variant.targetCoordinate
    }

    private func roundedCoordinate(_ value: Double) -> Double {
        (value * 1000).rounded() / 1000
    }
}

private struct MapFilterBar: View {
    @EnvironmentObject private var languageManager: LanguageManager

    @Binding var selectedAreaFilter: MapAreaFilter
    @Binding var selectedTypeFilter: MapUtilityTypeFilter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            filterTitle(L10n.text(.mapFilterArea, for: languageManager))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MapAreaFilter.allCases) { filter in
                        FilterChip(
                            title: filter.displayName(for: languageManager),
                            isSelected: selectedAreaFilter == filter
                        ) {
                            selectedAreaFilter = filter
                        }
                    }
                }
            }

            filterTitle(L10n.text(.mapFilterUtilityType, for: languageManager))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MapUtilityTypeFilter.allCases) { filter in
                        FilterChip(
                            title: filter.displayName(for: languageManager),
                            isSelected: selectedTypeFilter == filter
                        ) {
                            selectedTypeFilter = filter
                        }
                    }
                }
            }
        }
    }

    private func filterTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

private struct DeveloperDisplayControls: View {
    @EnvironmentObject private var languageManager: LanguageManager

    @Binding var showTargets: Bool
    @Binding var showVariantStarts: Bool
    @Binding var showLines: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(L10n.text(.targetPoints, for: languageManager), isOn: $showTargets)
            Toggle(L10n.text(.variantStartPoints, for: languageManager), isOn: $showVariantStarts)
            Toggle(L10n.text(.lineConnections, for: languageManager), isOn: $showLines)
        }
        .font(.caption)
        .toggleStyle(.switch)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.accent : AppTheme.cardBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct MapCanvas: View {
    @EnvironmentObject private var languageManager: LanguageManager

    private let coordinateSpaceName = "tacticalMapCanvas"

    let containerSize: CGSize
    let mapImageName: String
    let imageSize: CGSize
    let groups: [LineupGroup]
    let editedCoordinates: [MapPointKey: CGPoint]
    let developerModeEnabled: Bool
    let showDeveloperTargets: Bool
    let showDeveloperVariantStarts: Bool
    let showDeveloperLines: Bool
    let zoomScale: CGFloat
    let onSelect: (LineupGroup) -> Void
    let onSelectCluster: (LineupCluster) -> Void
    let onCoordinateChanged: (LineupGroup, LineupVariant?, MapPointKind, CGPoint) -> Void
    let onCoordinateEnded: (LineupGroup, LineupVariant?, MapPointKind, CGPoint) -> Void

    var body: some View {
        let imageRect = fittedImageRect(
            imageSize: imageSize,
            containerSize: containerSize
        )
        let clusters = clusteredGroups(in: imageRect)

        ZStack {
            Image(mapImageName)
                .resizable()
                .scaledToFit()
                .frame(width: containerSize.width, height: containerSize.height)

            if groups.isEmpty {
                EmptyStateView(
                    systemImage: "tray",
                    title: L10n.text(.emptyUtilities, for: languageManager),
                    message: L10n.text(.emptyUtilitiesMessage, for: languageManager)
                )
                .padding(18)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(20)
            } else if developerModeEnabled {
                if showDeveloperLines {
                    ForEach(groups) { group in
                        ForEach(group.variants) { variant in
                            let startPoint = pointLocation(
                                for: variantStartCoordinate(for: group, variant: variant),
                                in: imageRect
                            )
                            let targetPoint = pointLocation(
                                for: variantTargetCoordinate(for: group, variant: variant),
                                in: imageRect
                            )

                            Path { path in
                                path.move(to: startPoint)
                                path.addLine(to: targetPoint)
                            }
                            .stroke(group.type.color.opacity(0.75), lineWidth: 2)
                        }
                    }
                }

                if showDeveloperTargets {
                    ForEach(groups) { group in
                        let targetPoint = pointLocation(for: groupTargetCoordinate(for: group), in: imageRect)

                        draggableGroupTarget(group: group, imageRect: imageRect)
                            .position(targetPoint)
                    }
                }

                if showDeveloperVariantStarts {
                    ForEach(groups) { group in
                        ForEach(group.variants) { variant in
                            let startPoint = pointLocation(
                                for: variantStartCoordinate(for: group, variant: variant),
                                in: imageRect
                            )

                            draggableVariantStart(group: group, variant: variant, imageRect: imageRect)
                                .position(startPoint)
                        }
                    }
                }
            } else {
                ForEach(clusters) { cluster in
                    if cluster.groups.count > 1 {
                        Button {
                            onSelectCluster(cluster)
                        } label: {
                            ClusterPoint(count: cluster.groups.count)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .position(cluster.center)
                        .accessibilityLabel(
                            "\(cluster.groups.count) \(L10n.text(.clusteredUtilities, for: languageManager))"
                        )
                    } else if let group = cluster.groups.first {
                        Button {
                            onSelect(group)
                        } label: {
                            UtilityPoint(group: group)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .position(cluster.center)
                    }
                }
            }
        }
        .frame(width: containerSize.width, height: containerSize.height)
        .coordinateSpace(name: coordinateSpaceName)
    }

    private func clusteredGroups(in imageRect: CGRect) -> [LineupCluster] {
        if developerModeEnabled {
            return groups.map { group in
                LineupCluster(
                    groups: [group],
                    center: pointLocation(for: groupTargetCoordinate(for: group), in: imageRect)
                )
            }
        }

        let screenDistance = clusterDistance(for: zoomScale)
        var clusters: [LineupCluster] = []

        for group in groups {
            let point = pointLocation(for: groupTargetCoordinate(for: group), in: imageRect)

            if let index = clusters.firstIndex(where: { cluster in
                distance(from: cluster.center, to: point) * max(zoomScale, 1) <= screenDistance
            }) {
                clusters[index].add(group, at: point)
            } else {
                clusters.append(LineupCluster(groups: [group], center: point))
            }
        }

        return clusters
    }

    private func clusterDistance(for zoomScale: CGFloat) -> CGFloat {
        switch zoomScale {
        case ..<1.5:
            return 92
        case ..<2.0:
            return 76
        case ..<3.0:
            return 52
        default:
            return 36
        }
    }

    private func draggableGroupTarget(
        group: LineupGroup,
        imageRect: CGRect
    ) -> some View {
        EditableMapPoint(
            title: group.targetName.value(for: languageManager),
            group: group,
            kind: .groupTarget,
            coordinate: groupTargetCoordinate(for: group)
        )
            .frame(width: 124, height: 76)
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(
                    minimumDistance: 0,
                    coordinateSpace: .named(coordinateSpaceName)
                )
                .onChanged { value in
                    let newCoordinate = normalizedCoordinate(from: value.location, in: imageRect)
                    onCoordinateChanged(group, nil, .groupTarget, newCoordinate)
                }
                .onEnded { value in
                    let newCoordinate = normalizedCoordinate(from: value.location, in: imageRect)
                    onCoordinateEnded(group, nil, .groupTarget, newCoordinate)
                }
            )
    }

    private func draggableVariantStart(
        group: LineupGroup,
        variant: LineupVariant,
        imageRect: CGRect
    ) -> some View {
        EditableMapPoint(
            title: variant.name.value(for: languageManager),
            group: group,
            kind: .variantStart,
            coordinate: variantStartCoordinate(for: group, variant: variant)
        )
            .frame(width: 124, height: 76)
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(
                    minimumDistance: 0,
                    coordinateSpace: .named(coordinateSpaceName)
                )
                .onChanged { value in
                    let newCoordinate = normalizedCoordinate(from: value.location, in: imageRect)
                    onCoordinateChanged(group, variant, .variantStart, newCoordinate)
                }
                .onEnded { value in
                    let newCoordinate = normalizedCoordinate(from: value.location, in: imageRect)
                    onCoordinateEnded(group, variant, .variantStart, newCoordinate)
                }
            )
    }

    private func fittedImageRect(imageSize: CGSize, containerSize: CGSize) -> CGRect {
        let imageAspectRatio = imageSize.width / imageSize.height
        let containerAspectRatio = containerSize.width / containerSize.height

        let fittedSize: CGSize
        if imageAspectRatio > containerAspectRatio {
            fittedSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspectRatio
            )
        } else {
            fittedSize = CGSize(
                width: containerSize.height * imageAspectRatio,
                height: containerSize.height
            )
        }

        let offsetX = (containerSize.width - fittedSize.width) / 2
        let offsetY = (containerSize.height - fittedSize.height) / 2

        return CGRect(
            x: offsetX,
            y: offsetY,
            width: fittedSize.width,
            height: fittedSize.height
        )
    }

    private func groupTargetCoordinate(for group: LineupGroup) -> CGPoint {
        let key = MapPointKey(entityID: group.id, kind: .groupTarget)

        if let editedCoordinate = editedCoordinates[key] {
            return editedCoordinate
        }

        return group.targetCoordinate
    }

    private func variantStartCoordinate(for group: LineupGroup, variant: LineupVariant) -> CGPoint {
        let key = MapPointKey(entityID: variant.id, kind: .variantStart)

        if let editedCoordinate = editedCoordinates[key] {
            return editedCoordinate
        }

        return variant.startCoordinate
    }

    private func variantTargetCoordinate(for group: LineupGroup, variant: LineupVariant) -> CGPoint {
        let key = MapPointKey(entityID: group.id, kind: .groupTarget)

        if let editedCoordinate = editedCoordinates[key] {
            return editedCoordinate
        }

        return variant.targetCoordinate
    }

    private func pointLocation(for coordinate: CGPoint, in imageRect: CGRect) -> CGPoint {
        CGPoint(
            x: imageRect.minX + imageRect.width * coordinate.x,
            y: imageRect.minY + imageRect.height * coordinate.y
        )
    }

    private func normalizedCoordinate(from location: CGPoint, in imageRect: CGRect) -> CGPoint {
        let mapX = (location.x - imageRect.minX) / imageRect.width
        let mapY = (location.y - imageRect.minY) / imageRect.height

        return CGPoint(
            x: clamped(mapX),
            y: clamped(mapY)
        )
    }

    private func distance(from firstPoint: CGPoint, to secondPoint: CGPoint) -> CGFloat {
        let deltaX = firstPoint.x - secondPoint.x
        let deltaY = firstPoint.y - secondPoint.y

        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }

    private func clamped(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }
}

private struct UtilityPoint: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let group: LineupGroup

    var body: some View {
        MapMarkerView(
            type: group.type,
            markerSize: 28
        )
            .accessibilityLabel(
                "\(group.targetName.value(for: languageManager)), \(group.type.displayName(for: languageManager))"
            )
    }
}

private struct ClusterPoint: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(AppTheme.accent)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(.white, lineWidth: 2)
            }
            .shadow(radius: 4)
            .frame(width: 44, height: 44)
    }
}

private struct EditableMapPoint: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let title: String
    let group: LineupGroup
    let kind: MapPointKind
    let coordinate: CGPoint

    var body: some View {
        MapMarkerView(
            type: group.type,
            title: labelText,
            coordinate: coordinate,
            showsDeveloperInfo: true,
            markerSize: kind == .groupTarget ? 34 : 24
        )
    }

    private var labelText: String {
        "\(shortName) \(kind.displayName(for: languageManager))"
    }

    private var shortName: String {
        let parts = title.split(separator: " ")

        if parts.count > 1 {
            return parts.prefix(2).joined(separator: " ")
        }

        return title
    }
}

private struct ClusterLineupSheet: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let cluster: LineupCluster
    let onSelect: (LineupGroup) -> Void

    var body: some View {
        NavigationStack {
            List(cluster.groups) { group in
                Button {
                    dismiss()
                    onSelect(group)
                } label: {
                    HStack(spacing: 12) {
                        UtilityPoint(group: group)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.targetName.value(for: languageManager))
                                .font(.headline)
                            Text(group.type.displayName(for: languageManager))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(L10n.text(.variantCount(group.variants.count), for: languageManager))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle(L10n.text(.clusteredUtilities, for: languageManager))
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

private enum MapAreaFilter: CaseIterable, Hashable, Identifiable {
    case featured
    case aSite
    case bSite
    case mid
    case tSide
    case ctSide

    var id: Self {
        self
    }

    func displayName(for languageManager: LanguageManager) -> String {
        switch self {
        case .featured:
            return L10n.text(.mapFilterFeatured, for: languageManager)
        case .aSite:
            return LineupCategory.aSite.displayName(for: languageManager)
        case .bSite:
            return LineupCategory.bSite.displayName(for: languageManager)
        case .mid:
            return LineupCategory.mid.displayName(for: languageManager)
        case .tSide:
            return LineupCategory.tSide.displayName(for: languageManager)
        case .ctSide:
            return LineupCategory.ctSide.displayName(for: languageManager)
        }
    }

    func matches(_ group: LineupGroup) -> Bool {
        switch self {
        case .featured:
            return group.isFeatured
        case .aSite:
            return group.category == .aSite
        case .bSite:
            return group.category == .bSite
        case .mid:
            return group.category == .mid
        case .tSide:
            return group.category == .tSide
        case .ctSide:
            return group.category == .ctSide
        }
    }
}

private enum MapUtilityTypeFilter: CaseIterable, Hashable, Identifiable {
    case all
    case smoke
    case flash
    case molotov
    case he

    var id: Self {
        self
    }

    func displayName(for languageManager: LanguageManager) -> String {
        switch self {
        case .all:
            return L10n.text(.mapFilterAll, for: languageManager)
        case .smoke:
            return UtilityType.smoke.displayName(for: languageManager)
        case .flash:
            return UtilityType.flash.displayName(for: languageManager)
        case .molotov:
            return UtilityType.molotov.displayName(for: languageManager)
        case .he:
            return UtilityType.he.displayName(for: languageManager)
        }
    }

    func matches(_ group: LineupGroup) -> Bool {
        switch self {
        case .all:
            return true
        case .smoke:
            return group.type == .smoke
        case .flash:
            return group.type == .flash
        case .molotov:
            return group.type == .molotov
        case .he:
            return group.type == .he
        }
    }
}

private struct LineupCluster: Identifiable {
    var groups: [LineupGroup]
    var center: CGPoint

    var id: String {
        groups.map { $0.id }.joined(separator: "-")
    }

    mutating func add(_ group: LineupGroup, at point: CGPoint) {
        let existingCount = CGFloat(groups.count)
        center = CGPoint(
            x: (center.x * existingCount + point.x) / (existingCount + 1),
            y: (center.y * existingCount + point.y) / (existingCount + 1)
        )
        groups.append(group)
    }
}

private enum MapPointKind: String, Hashable {
    case groupTarget
    case variantStart

    func displayName(for languageManager: LanguageManager) -> String {
        switch self {
        case .groupTarget:
            return L10n.text(.targetPoint, for: languageManager)
        case .variantStart:
            return L10n.text(.startPoint, for: languageManager)
        }
    }

    func entityID(group: LineupGroup, variant: LineupVariant?) -> String {
        switch self {
        case .groupTarget:
            return group.id
        case .variantStart:
            return variant?.id ?? group.id
        }
    }

    var xFieldName: String {
        switch self {
        case .groupTarget:
            return "targetMapX"
        case .variantStart:
            return "startMapX"
        }
    }

    var yFieldName: String {
        switch self {
        case .groupTarget:
            return "targetMapY"
        case .variantStart:
            return "startMapY"
        }
    }
}

private struct MapPointKey: Hashable {
    let entityID: String
    let kind: MapPointKind
}

private struct EditedLineupCoordinate: Identifiable {
    let id: MapPointKey
    let displayName: String
    let kind: MapPointKind
    let mapX: Double
    let mapY: Double

    var coordinateText: String {
        String(
            format: "%@: %.3f, %@: %.3f",
            kind.xFieldName,
            mapX,
            kind.yFieldName,
            mapY
        )
    }
}

private struct DeveloperCoordinatePanel: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let coordinate: EditedLineupCoordinate?
    let statusMessage: String?
    let onCopyCoordinates: () -> Void
    let onCopyJSON: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let coordinate {
                Text(sectionTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(coordinate.displayName) \(coordinate.kind.displayName(for: languageManager))")
                    .font(.subheadline.weight(.semibold))

                Text(coordinate.coordinateText)
                    .font(.system(.footnote, design: .monospaced))
            } else {
                Text(L10n.text(.noEditedCoordinate, for: languageManager))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button(L10n.text(.copyCoordinates, for: languageManager), action: onCopyCoordinates)
                    .disabled(coordinate == nil)

                Button(L10n.text(.copyJSON, for: languageManager), action: onCopyJSON)
            }
            .buttonStyle(.bordered)

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
    }

    private var sectionTitle: String {
        if statusMessage == nil {
            return L10n.text(.liveCoordinates, for: languageManager)
        }

        return L10n.text(.lastEditedCoordinate, for: languageManager)
    }
}

private struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let minScale: CGFloat
    let maxScale: CGFloat
    let doubleTapScale: CGFloat
    let isPointEditingEnabled: Bool
    @Binding var zoomScale: CGFloat
    let content: Content

    init(
        minScale: CGFloat,
        maxScale: CGFloat,
        doubleTapScale: CGFloat,
        isPointEditingEnabled: Bool,
        zoomScale: Binding<CGFloat>,
        @ViewBuilder content: () -> Content
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.doubleTapScale = doubleTapScale
        self.isPointEditingEnabled = isPointEditingEnabled
        self._zoomScale = zoomScale
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let hostingController = UIHostingController(rootView: content)

        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.panGestureRecognizer.minimumNumberOfTouches = isPointEditingEnabled ? 2 : 1
        scrollView.backgroundColor = .clear

        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        let doubleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)

        context.coordinator.hostingController = hostingController
        context.coordinator.scrollView = scrollView

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.hostingController?.rootView = content
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
        scrollView.panGestureRecognizer.minimumNumberOfTouches = isPointEditingEnabled ? 2 : 1
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableScrollView
        var hostingController: UIHostingController<Content>?
        weak var scrollView: UIScrollView?

        init(parent: ZoomableScrollView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController?.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let newZoomScale = scrollView.zoomScale

            if abs(parent.zoomScale - newZoomScale) > 0.01 {
                DispatchQueue.main.async {
                    self.parent.zoomScale = newZoomScale
                }
            }
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView else {
                return
            }

            if scrollView.zoomScale > parent.minScale {
                scrollView.setZoomScale(parent.minScale, animated: true)
                return
            }

            let tapPoint = gesture.location(in: hostingController?.view)
            let zoomSize = CGSize(
                width: scrollView.bounds.width / parent.doubleTapScale,
                height: scrollView.bounds.height / parent.doubleTapScale
            )
            let zoomRect = CGRect(
                x: tapPoint.x - zoomSize.width / 2,
                y: tapPoint.y - zoomSize.height / 2,
                width: zoomSize.width,
                height: zoomSize.height
            )

            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}

#Preview {
    let languageManager = LanguageManager()
    let developerSettings = DeveloperSettings()

    NavigationStack {
        TacticalMapView(
            map: LineupStore.mirageMap
        )
        .environmentObject(languageManager)
        .environmentObject(developerSettings)
        .environmentObject(FavoriteStore())
    }
}
