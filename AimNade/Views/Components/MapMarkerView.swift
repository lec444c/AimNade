import SwiftUI

struct MapMarkerView: View {
    let type: UtilityType
    let markerSize: CGFloat

    init(
        type: UtilityType,
        markerSize: CGFloat = 34
    ) {
        self.type = type
        self.markerSize = markerSize
    }

    var body: some View {
        Image(systemName: type.systemImageName)
            .font(.system(size: markerSize * 0.42, weight: .bold))
            .foregroundStyle(type == .flash ? .black : .white)
            .frame(width: markerSize, height: markerSize)
            .background(type.color)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(.white, lineWidth: 2)
            }
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }
}
