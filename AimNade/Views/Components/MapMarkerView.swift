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
            .background(type.color.gradient)
            .clipShape(RoundedRectangle(cornerRadius: markerSize * 0.32, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: markerSize * 0.32, style: .continuous)
                    .stroke(.white.opacity(0.30), lineWidth: 1)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }
}
