import Foundation
import UIKit
import AVFoundation

public protocol OverlayImageSettable {
    var sourceView: UIView { get }
    var url: URL? { get }
    
    func makeLottieView() -> UIView
    func makeImageView() -> UIView
    func makeAnimatedImageView() -> UIView
}

public protocol OverlayPlayable {
    func play()
}

public enum OverlayPreviewItem {
    case gif(OverlayImageSettable & OverlayPlayable)
    case image(OverlayImageSettable)
    case animation(OverlayImageSettable & OverlayPlayable)
    case video(item: AVPlayerItem, settable: OverlayImageSettable & OverlayPlayable)
    case view(sourceView: UIView)
    case loadable(state: (@escaping ((OverlayLoadablaItemState) -> Void)) -> (), sourceView: UIView)
    
    var sourceView: UIView {
        switch self {
        case .gif(let settable):
            return settable.sourceView
        case .image(let settable):
            return settable.sourceView
        case .animation(let settable):
            return settable.sourceView
        case .video(_, let settable):
            return settable.sourceView
        case .loadable(_, let view):
            return view
        case .view(let view):
            return view
        }
    }
    
    var sourceCopy: UIView {
        switch self {
        case let .gif(settable):
            return settable.makeAnimatedImageView()
        case let .image(settable):
            return settable.makeImageView()
        case let .animation(settable):
            return settable.makeLottieView()
        case .video(_, let settable):
            return settable.makeImageView()
        case .loadable(_, let sourceView):
            if let imageView = sourceView as? UIImageView {
                return UIImageView(image: imageView.image)
            } else {
                return sourceView.snapshotView(afterScreenUpdates: false) ?? UIView()
            }
        case .view(let sourceView):
            return sourceView.snapshotView(afterScreenUpdates: false) ?? UIView()
        }
    }
}

public enum OverlayLoadablaItemState {
    case loading
    case loaded(UIView)
    case failed
}
