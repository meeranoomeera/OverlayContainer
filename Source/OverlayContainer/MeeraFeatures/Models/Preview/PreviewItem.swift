import Foundation
import UIKit
import AVFoundation
//import Kingfisher
//import Lottie

public enum PreviewItem {
    case gif(sourceView: UIView, url: URL?)
    case image(sourceView: UIView, url: URL?)
    case animation(sourceView: UIView, url: URL?)
    case video(item: AVPlayerItem, sourceView: UIView)
    case view(sourceView: UIView)
    case loadable(state: (@escaping ((LoadablaItemState) -> Void)) -> (), sourceView: UIView)
    
    var sourceView: UIView {
        switch self {
        case .gif(let view, _):
            return view
        case .image(let view, _):
            return view
        case .animation(let view, _):
            return view
        case .video(_, let view):
            return view
        case .loadable(_, let view):
            return view
        case .view(let view):
            return view
        }
    }
    
    var sourceCopy: UIView {
        switch self {
        case let .gif(_, url):
            return UIView()
            //			let view = AnimatedImageView()
            //			view.kf.setImage(
            //				with: url,
            //				options: [.backgroundDecode]
            //			)
            //			return view
        case let .image(sourceView, url):
            //			view.kf.setImage(
            //				with: url,
            //				options: [.backgroundDecode]
            //			)
//            return sourceView
            if let imageView = sourceView as? UIImageView {
                return UIImageView(image: imageView.image)
            }
            return sourceView
        case let .animation(_, url):
            return UIView()
            //			let view = LottieAnimationView()
            //			if let url = url {
            //				LottieAnimation.loadedFrom(url: url) { [weak view] animation in
            //					view?.animation = animation
            //				}
            //			}
            //			return view
        case .video(_, let sourceView), .loadable(_, let sourceView):
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

public enum LoadablaItemState {
    case loading
    case loaded(UIView)
    case failed
}

// Mark: - Playable
public protocol OverlayPlayable {
    func play()
}

extension UIView: OverlayPlayable {
    @objc public func play() {}
}

//extension AnimatedImageView {
//	override func play() {
//		startAnimating()
//	}
//}
//
//extension LottieAnimationView {
//	override func play() {
//		if animation != nil {
//			play(toProgress: 1, loopMode: .loop)
//		} else {
//			animationLoaded = { view, animation in
//				view.play(toProgress: 1, loopMode: .loop)
//			}
//		}
//	}
//}
