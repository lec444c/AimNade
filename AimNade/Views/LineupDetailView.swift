import SwiftUI
import UIKit

struct LineupDetailView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @State private var isImagePreviewPresented = false
    @State private var selectedImageIndex = 0
    @State private var isImagesExpanded = false

    let group: LineupGroup
    let variant: LineupVariant

    private var teachingImages: [TeachingImageItem] {
        [
            TeachingImageItem(
                title: L10n.text(.startPosition, for: languageManager),
                systemImage: "figure.stand",
                imageName: variant.positionImageName
            ),
            TeachingImageItem(
                title: L10n.text(.aimPoint, for: languageManager),
                systemImage: "scope",
                imageName: variant.aimImageName
            ),
            TeachingImageItem(
                title: L10n.text(.result, for: languageManager),
                systemImage: "target",
                imageName: variant.resultImageName
            )
        ]
    }

    private var isFavorite: Bool {
        favoriteStore.isFavoriteVariant(variant)
    }

    var body: some View {
        List {
            Section(L10n.text(.overview, for: languageManager)) {
                detailRow(L10n.text(.name, for: languageManager), variant.name.value(for: languageManager))
                badgeRow(
                    L10n.text(.type, for: languageManager),
                    UtilityBadge.utilityType(group.type, for: languageManager)
                )
                badgeRow(
                    L10n.text(.side, for: languageManager),
                    UtilityBadge.side(group.side)
                )
                badgeRow(
                    L10n.text(.category, for: languageManager),
                    UtilityBadge.category(group.category, for: languageManager)
                )
                badgeRow(
                    L10n.text(.difficulty, for: languageManager),
                    UtilityBadge.difficulty(variant.difficultyDisplayName(for: languageManager))
                )
            }

            Section(L10n.text(.position, for: languageManager)) {
                detailRow(L10n.text(.startArea, for: languageManager), variant.startArea.value(for: languageManager))
                detailRow(L10n.text(.targetArea, for: languageManager), variant.targetArea.value(for: languageManager))
                detailRow(L10n.text(.spawnRequirement, for: languageManager), variant.spawnRequirement.value(for: languageManager))
            }

            Section(L10n.text(.lineupSteps, for: languageManager)) {
                Text(variant.throwMethod.value(for: languageManager))
                    .font(.body)
                    .lineSpacing(3)
            }

            Section {
                DisclosureGroup(isExpanded: $isImagesExpanded) {
                    VStack(spacing: 12) {
                        ForEach(teachingImages.indices, id: \.self) { index in
                            TeachingImageCard(
                                item: teachingImages[index],
                                placeholderText: L10n.text(.placeholder, for: languageManager)
                            ) {
                                selectedImageIndex = index
                                isImagePreviewPresented = true
                            }
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    Label(
                        L10n.text(.teachingImages, for: languageManager),
                        systemImage: "photo.on.rectangle"
                    )
                }
                .listRowInsets(
                    EdgeInsets(
                        top: 8,
                        leading: AppTheme.pagePadding,
                        bottom: 8,
                        trailing: AppTheme.pagePadding
                    )
                )
            }

            Section(L10n.text(.notes, for: languageManager)) {
                Text(variant.description.value(for: languageManager))
                    .font(.body)
                    .lineSpacing(3)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle(variant.name.value(for: languageManager))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favoriteStore.toggleVariant(variant)
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                }
                .accessibilityLabel(
                    L10n.text(isFavorite ? .removeFavorite : .addFavorite, for: languageManager)
                )
            }
        }
        .fullScreenCover(isPresented: $isImagePreviewPresented) {
            LineupImagePreviewView(
                items: teachingImages,
                initialIndex: selectedImageIndex,
                placeholderText: L10n.text(.placeholder, for: languageManager)
            )
            .environmentObject(languageManager)
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }

    private func badgeRow(_ title: String, _ badge: UtilityBadge) -> some View {
        HStack(alignment: .center) {
            Text(title)
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            badge
        }
    }
}

private struct TeachingImageItem: Identifiable {
    let title: String
    let systemImage: String
    let imageName: String

    var id: String {
        imageName
    }
}

private struct TeachingImageCard: View {
    let item: TeachingImageItem
    let placeholderText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Label(item.title, systemImage: item.systemImage)
                    .font(.headline)

                Group {
                    if let image = UIImage(named: item.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(AppTheme.cardBackground)
                            .frame(height: 150)
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.title2)
                                    Text(placeholderText)
                                        .font(.subheadline)
                                }
                                .foregroundStyle(AppTheme.secondaryText)
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
            }
            .padding(AppTheme.cardPadding)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .accessibilityLabel(item.title)
    }
}

private struct LineupImagePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedIndex: Int

    let items: [TeachingImageItem]
    let placeholderText: String

    init(items: [TeachingImageItem], initialIndex: Int, placeholderText: String) {
        self.items = items
        self.placeholderText = placeholderText
        _selectedIndex = State(initialValue: LineupImagePreviewView.validIndex(initialIndex, itemCount: items.count))
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if items.isEmpty {
                PreviewPlaceholderView(placeholderText: placeholderText)
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(items.indices, id: \.self) { index in
                        PreviewImagePage(item: items[index], placeholderText: placeholderText)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .overlay(alignment: .top) {
            previewHeader
        }
    }

    private var previewHeader: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            .accessibilityLabel(L10n.text(.close, for: languageManager))

            Text(currentTitle)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.75), Color.black.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    private var currentTitle: String {
        guard items.indices.contains(selectedIndex) else {
            return ""
        }

        return items[selectedIndex].title
    }

    private static func validIndex(_ index: Int, itemCount: Int) -> Int {
        guard itemCount > 0 else {
            return 0
        }

        return min(max(index, 0), itemCount - 1)
    }
}

private struct PreviewImagePage: View {
    let item: TeachingImageItem
    let placeholderText: String

    var body: some View {
        if let image = UIImage(named: item.imageName) {
            ZoomableImageView(image: image)
                .ignoresSafeArea()
        } else {
            PreviewPlaceholderView(placeholderText: placeholderText)
        }
    }
}

private struct PreviewPlaceholderView: View {
    let placeholderText: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)

            Text(placeholderText)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

private struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        context.coordinator.imageView = imageView
        context.coordinator.image = image

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.image = image
        context.coordinator.imageView?.image = image

        DispatchQueue.main.async {
            context.coordinator.resetImageLayout(in: scrollView)
        }
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        var image: UIImage?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImage(in: scrollView)
        }

        func resetImageLayout(in scrollView: UIScrollView) {
            guard let imageView, let image, scrollView.bounds.width > 0, scrollView.bounds.height > 0 else {
                return
            }

            scrollView.zoomScale = 1.0

            let fittedSize = fittedImageSize(imageSize: image.size, containerSize: scrollView.bounds.size)
            imageView.frame = CGRect(origin: .zero, size: fittedSize)
            scrollView.contentSize = fittedSize
            centerImage(in: scrollView)
        }

        private func fittedImageSize(imageSize: CGSize, containerSize: CGSize) -> CGSize {
            guard imageSize.width > 0, imageSize.height > 0, containerSize.width > 0, containerSize.height > 0 else {
                return .zero
            }

            let imageRatio = imageSize.width / imageSize.height
            let containerRatio = containerSize.width / containerSize.height

            if imageRatio > containerRatio {
                let width = containerSize.width
                return CGSize(width: width, height: width / imageRatio)
            } else {
                let height = containerSize.height
                return CGSize(width: height * imageRatio, height: height)
            }
        }

        private func centerImage(in scrollView: UIScrollView) {
            guard let imageView else {
                return
            }

            let boundsSize = scrollView.bounds.size
            var frameToCenter = imageView.frame

            frameToCenter.origin.x = frameToCenter.size.width < boundsSize.width
                ? (boundsSize.width - frameToCenter.size.width) / 2
                : 0
            frameToCenter.origin.y = frameToCenter.size.height < boundsSize.height
                ? (boundsSize.height - frameToCenter.size.height) / 2
                : 0

            imageView.frame = frameToCenter
        }
    }
}

#Preview {
    let group = LineupStore.mirageMap.lineupGroups[0]

    NavigationStack {
        LineupDetailView(group: group, variant: group.variants[0])
            .environmentObject(LanguageManager())
            .environmentObject(FavoriteStore())
    }
}
