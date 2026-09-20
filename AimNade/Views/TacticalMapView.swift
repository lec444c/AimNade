import SwiftUI
import UIKit

struct TacticalMapView: View {
    let map: Map
    let accentColor: Color

    init(map: Map, accentColor: Color = AppTheme.accent) {
        self.map = map
        self.accentColor = accentColor
    }

    var body: some View {
        GeometryReader { geometry in
            let imageSize = UIImage(named: map.imageName)?.size ?? CGSize(width: 1, height: 1)
            let containerSize = fittedContainerSize(
                imageSize: imageSize,
                availableSize: geometry.size
            )

            ZoomableScrollView(
                minScale: 1,
                maxScale: 4,
                doubleTapScale: 2.5
            ) {
                Image(map.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: containerSize.width, height: containerSize.height)
                    .accessibilityHidden(true)
            }
            .frame(width: containerSize.width, height: containerSize.height)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.mapCornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.mapCornerRadius, style: .continuous)
                    .stroke(accentColor.opacity(0.24), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.bottom, 8)
        .background(AppTheme.background)
    }

    private func fittedContainerSize(imageSize: CGSize, availableSize: CGSize) -> CGSize {
        let availableWidth = max(availableSize.width, 1)
        let availableHeight = max(availableSize.height, 1)
        let imageRatio = max(imageSize.width / max(imageSize.height, 1), 0.01)
        let availableRatio = availableWidth / availableHeight

        if imageRatio > availableRatio {
            return CGSize(width: availableWidth, height: availableWidth / imageRatio)
        }

        return CGSize(width: availableHeight * imageRatio, height: availableHeight)
    }
}

private struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let minScale: CGFloat
    let maxScale: CGFloat
    let doubleTapScale: CGFloat
    let content: Content

    init(
        minScale: CGFloat,
        maxScale: CGFloat,
        doubleTapScale: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.doubleTapScale = doubleTapScale
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
    TacticalMapView(map: LineupStore.mirageMap)
}
