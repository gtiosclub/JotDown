import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let minZoom: CGFloat
    let maxZoom: CGFloat
    @Binding var currentZoom: CGFloat

    init(
        minZoom: CGFloat = 0.67,
        maxZoom: CGFloat = 1.5,
        currentZoom: Binding<CGFloat> = .constant(1.0),
        @ViewBuilder content: () -> Content
    ) {
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self._currentZoom = currentZoom
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = minZoom
        scrollView.maximumZoomScale = maxZoom
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false

        // Create hosting controller for SwiftUI content
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        scrollView.addSubview(hostingController.view)
        context.coordinator.hostingController = hostingController

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // Update the hosting controller's content with animation support
        if let transaction = context.transaction.animation {
            withAnimation(transaction) {
                context.coordinator.hostingController?.rootView = content
            }
        } else {
            context.coordinator.hostingController?.rootView = content
        }

        // Update zoom scale if needed
        if scrollView.zoomScale != currentZoom {
            scrollView.setZoomScale(currentZoom, animated: false)
        }

        // Layout the content
        if let hostingView = context.coordinator.hostingController?.view {
            // Force layout update to respect SwiftUI animations
            hostingView.layoutIfNeeded()

            let contentSize = hostingView.intrinsicContentSize
            hostingView.frame = CGRect(origin: .zero, size: contentSize)
            scrollView.contentSize = contentSize

            // Center content if it's smaller than the scroll view
            // centerContentIfNeeded(scrollView: scrollView)

            // Set initial content offset to center on first layout
            if !context.coordinator.hasSetInitialOffset {
                let centerX = (scrollView.contentSize.width - 400) / 2
                let centerY = (scrollView.contentSize.height - 400) / 2
                scrollView.setContentOffset(CGPoint(x: max(0, centerX), y: max(0, centerY)), animated: true)
                context.coordinator.hasSetInitialOffset = true
            }
        }
    }

    private func centerContentIfNeeded(scrollView: UIScrollView) {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        // Calculate the actual zoomed content size
        let zoomedWidth = contentSize.width * scrollView.zoomScale
        let zoomedHeight = contentSize.height * scrollView.zoomScale

        // Only add insets when content is smaller than scroll view
        // This centers the content when zoomed out, but allows full panning when zoomed in
        let horizontalInset = max(0, (scrollViewSize.width - zoomedWidth) / 2)
        let verticalInset = max(0, (scrollViewSize.height - zoomedHeight) / 2)

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: ZoomableScrollView
        var hostingController: UIHostingController<Content>?
        var hasSetInitialOffset = false

        init(_ parent: ZoomableScrollView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController?.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // Update the binding
            parent.currentZoom = scrollView.zoomScale

            // Center content if needed
            parent.centerContentIfNeeded(scrollView: scrollView)
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            parent.currentZoom = scale
        }
    }
}
