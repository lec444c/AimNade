import Foundation
import SwiftUI

struct MapMarkerView: View {
    let type: UtilityType
    let title: String?
    let coordinate: CGPoint?
    let showsDeveloperInfo: Bool
    let markerSize: CGFloat
    let isSelected: Bool

    init(
        type: UtilityType,
        title: String? = nil,
        coordinate: CGPoint? = nil,
        showsDeveloperInfo: Bool = false,
        markerSize: CGFloat = 34,
        isSelected: Bool = false
    ) {
        self.type = type
        self.title = title
        self.coordinate = coordinate
        self.showsDeveloperInfo = showsDeveloperInfo
        self.markerSize = markerSize
        self.isSelected = isSelected
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: type.systemImageName)
                .font(.system(size: markerSize * 0.42, weight: .bold))
                .foregroundStyle(type == .flash ? .black : .white)
                .frame(width: markerSize, height: markerSize)
                .background(type.color)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(isSelected ? AppTheme.tacticalOrange : .white, lineWidth: isSelected ? 3 : 2)
                }
                .shadow(
                    color: isSelected ? AppTheme.tacticalOrange.opacity(0.45) : .black.opacity(0.25),
                    radius: isSelected ? 8 : 3,
                    x: 0,
                    y: isSelected ? 0 : 1
                )
                .scaleEffect(isSelected ? 1.14 : 1)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())

            if showsDeveloperInfo {
                VStack(spacing: 2) {
                    if let title {
                        Text(title)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                    }

                    if let coordinate {
                        Text(Self.coordinateText(for: coordinate))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .foregroundStyle(AppTheme.primaryText)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .frame(minWidth: 44, minHeight: 44)
        .animation(.snappy(duration: 0.22), value: isSelected)
    }

    private static func coordinateText(for coordinate: CGPoint) -> String {
        String(format: "%.3f, %.3f", Double(coordinate.x), Double(coordinate.y))
    }
}
