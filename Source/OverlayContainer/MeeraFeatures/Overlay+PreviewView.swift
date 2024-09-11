import Foundation
import UIKit

extension OverlayContainerViewController {
    
    public func meera_invalidatePreviewView() {
        guard isViewLoaded else { return }
        if let meera_previewContainer {
            meera_previewContainer.removeFromSuperview()
        }
        
        meera_loadOverlayPinnedView()
    }
    
    internal func meera_loadOverlayPreviewView() {
        guard let previewViewConfig = configuration.overlayPreviewViewConfig(),
              let _previewItem = previewViewConfig.previewView else {
            return
        }
        
        let previewContainer = PassThroughView()
        overlayTranslationContainerView.insertSubview(previewContainer, belowSubview: overlayTranslationView)
        previewContainer.pinToSuperview(with: .zero , edges: [.left, .right, .top, .bottom])
        
        self.meera_previewContainer = previewContainer
        
        let previewCopy: UIView
        switch _previewItem {
        case .loadable:
            previewCopy = UIView()
        case .animation, .gif, .image, .video, .view:
            previewCopy = _previewItem.sourceCopy
        }
        
        previewCopy.translatesAutoresizingMaskIntoConstraints = false
        previewCopy.contentMode = .scaleAspectFit
        
        previewContainer.addSubview(previewCopy)
        
        setupPreviewConstraints(
            previewCopy: previewCopy,
            previewContainer: previewContainer,
            previewViewConfig: previewViewConfig,
            previewItem: _previewItem
        )
        meera_animatePreviewIn()
        
        (previewCopy as? OverlayPlayable)?.play()
    }
    
    private func setupPreviewConstraints(
        previewCopy: UIView,
        previewContainer: UIView,
        previewViewConfig: OverlayPreviewViewConfig,
        previewItem: OverlayPreviewItem
    ) {
        var constraints: [NSLayoutConstraint] = [
            previewCopy.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor),
            previewCopy.leadingAnchor.constraint(greaterThanOrEqualTo: previewContainer.leadingAnchor),
            previewCopy.topAnchor.constraint(greaterThanOrEqualTo: previewContainer.topAnchor),
            previewCopy.bottomAnchor.constraint(
                greaterThanOrEqualTo: overlayTranslationView.topAnchor,
                constant: -previewViewConfig.distanceToContainer
            ),
        ]
        
        if let options = previewViewConfig.previewSizeOption {
            options.forEach({
                switch $0 {
                case let .fixedPreviewSize(size):
                    constraints.append(contentsOf: [
                        previewCopy.widthAnchor.constraint(equalToConstant: size.width),
                        previewCopy.heightAnchor.constraint(equalToConstant: size.height),
                    ])
                case let .aspectRatio(ratio):
                    constraints.append(
                        previewCopy.widthAnchor.constraint(equalTo: previewCopy.heightAnchor, multiplier: ratio)
                    )
                case let .minHorizontalInset(value):
                    constraints.append(
                        previewCopy.leadingAnchor.constraint(greaterThanOrEqualTo: previewContainer.leadingAnchor, constant: value)
                    )
                case let .fillMinWidthRatio(value):
                    constraints.append(
                        previewCopy.widthAnchor.constraint(greaterThanOrEqualTo: previewContainer.widthAnchor, multiplier: value)
                    )
                case let .fillMinHeightRatio(value):
                    constraints.append(
                        previewCopy.heightAnchor.constraint(greaterThanOrEqualTo: previewContainer.heightAnchor, multiplier: value)
                    )
                case let .fillByMinSide(mult, ratio):
                    constraints.append(
                        previewCopy.widthAnchor.constraint(equalTo: previewCopy.heightAnchor, multiplier: ratio)
                    )
                    if ratio < 1 {
                        let restHeight: CGFloat = (UIScreen.main.bounds.height - configuration.maximumNotchHeight) * mult
                        previewCopy.heightAnchor.constraint(equalToConstant: restHeight).isActive = true
                    } else {
                        previewCopy.widthAnchor.constraint(equalTo: previewContainer.widthAnchor, multiplier: mult).isActive = true
                    }
                }
            })
        }
        
        constraints.forEach { $0.isActive = true }
        
        switch previewItem {
        case .gif, .image, .animation, .view:
            break
        case .video(let item, _):
            let playerView = PlayerView()
            playerView.translatesAutoresizingMaskIntoConstraints = false
            playerView.play(item)
            UIView.transition(
                with: previewCopy,
                duration: 0.2,
                options: [.transitionCrossDissolve]
            ) {
                previewCopy.addSubview(playerView)
            }
            NSLayoutConstraint.activate([
                playerView.leadingAnchor.constraint(equalTo: previewCopy.leadingAnchor),
                playerView.trailingAnchor.constraint(equalTo: previewCopy.trailingAnchor),
                playerView.topAnchor.constraint(equalTo: previewCopy.topAnchor),
                playerView.bottomAnchor.constraint(equalTo: previewCopy.bottomAnchor),
            ])
            
        case .loadable(let loadable, _):
            let activity = UIActivityIndicatorView(style: .large)
            activity.color = .white
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.hidesWhenStopped = true
            
            loadable { [weak previewCopy] state in
                switch state {
                case .loading:
                    guard let previewCopy = previewCopy else {
                        return
                    }
                    previewCopy.addSubview(activity)
                    (previewCopy as? UIImageView)?.image = nil
                    previewCopy.backgroundColor = .clear
                    activity.startAnimating()
                    NSLayoutConstraint.activate([
                        activity.centerXAnchor.constraint(equalTo: previewCopy.centerXAnchor),
                        activity.centerYAnchor.constraint(equalTo: previewCopy.centerYAnchor),
                    ])
                case .loaded(let view):
                    guard let previewCopy = previewCopy else {
                        return
                    }
                    activity.stopAnimating()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    UIView.transition(
                        with: previewCopy,
                        duration: 0.2,
                        options: [.transitionCrossDissolve]
                    ) {
                        previewCopy.addSubview(view)
                    }
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: previewCopy.leadingAnchor),
                        view.trailingAnchor.constraint(equalTo: previewCopy.trailingAnchor),
                        view.topAnchor.constraint(equalTo: previewCopy.topAnchor),
                        view.bottomAnchor.constraint(equalTo: previewCopy.bottomAnchor),
                    ])
                case .failed:
                    break
                }
            }
        }
        
        previewCopy.setNeedsLayout()
        previewContainer.layoutIfNeeded()
    }
    
    func meera_animatePreviewIn() {
        guard let previewViewConfig = configuration.overlayPreviewViewConfig(),
              let _previewItem = previewViewConfig.previewView else {
            return
        }
        
        let toPreviewView: UIView? = meera_previewContainer?.subviews.first
        let fromPreviewView: UIView? = _previewItem.sourceView
        let snapshot: UIView? = _previewItem.sourceCopy
        snapshot?.clipsToBounds = true
        
        if let fromPreviewView,
           let toPreviewView,
           let snapshot
        {
            snapshot.contentMode = fromPreviewView.contentMode
            toPreviewView.isHidden = true
            meera_previewContainer?.addSubview(snapshot)
            if case .loadable = _previewItem {
                snapshot.alpha = 1
            } else if ((previewViewConfig.previewTransitionOption?.contains(.fadeIn)) != nil) {
                snapshot.alpha = 0
            }
            
            snapshot.frame = overlayTranslationContainerView.convert(
                fromPreviewView.frame,
                from: fromPreviewView.superview
            )
        }
        
        baseAnimation(
            animations: { [weak self, weak snapshot] in
                if case .loadable = _previewItem {
                    snapshot?.alpha = 0
                } else if ((previewViewConfig.previewTransitionOption?.contains(.fadeIn)) != nil) {
                    snapshot?.alpha = 1
                }
                if let toPreviewView {
                    let shouldFadeIn = previewViewConfig
                        .previewTransitionOption?.contains(.viewToViewIn) ?? false
                    if shouldFadeIn && snapshot?.frame != .zero {
                        snapshot?.frame = self?.meera_previewContainer?.convert(
                            toPreviewView.frame,
                            from: toPreviewView.superview
                        ) ?? .zero
                    }
                    snapshot?.contentMode = toPreviewView.contentMode
                    snapshot?.layoutIfNeeded()
                }
            }, completion: { [weak self, weak snapshot, weak toPreviewView] uiViewAnimatingPosition in
                snapshot?.removeFromSuperview()
                toPreviewView?.isHidden = false
                self?.configuration.overlayDidDisplayPreview(view: toPreviewView)
            })
    }
    
    func meera_animatePreviewOut() {
        guard let previewViewConfig = configuration.overlayPreviewViewConfig(),
              let _previewItem = previewViewConfig.previewView else {
            return
        }
        
        let toPreviewView: UIView? = _previewItem.sourceView
        let fromPreviewView: UIView? = meera_previewContainer?.subviews.first
        let snapshot: UIView? = fromPreviewView?.snapshotView(afterScreenUpdates: false)
        snapshot?.clipsToBounds = true
        
        if let fromPreviewView,
           let snapshot {
            snapshot.contentMode = fromPreviewView.contentMode
            fromPreviewView.isHidden = true
            meera_previewContainer?.addSubview(snapshot)
            snapshot.frame = meera_previewContainer?.convert(
                fromPreviewView.frame,
                from: fromPreviewView.superview
            ) ?? .zero
        }
        
        
        baseAnimation(
            animations: { [weak self, weak snapshot, weak toPreviewView] in
                guard let toPreviewView else {
                    return
                }
                let toFrame = self?.overlayTranslationContainerView.convert(
                    toPreviewView.frame,
                    from: toPreviewView.superview
                ) ?? .zero
                if toFrame == .zero {
                    snapshot?.alpha = 0
                } else if ((previewViewConfig.previewTransitionOption?.contains(.viewToViewOut)) != nil) {
                    snapshot?.frame = toFrame
                }
                
                if ((previewViewConfig.previewTransitionOption?.contains(.cornerRadiusOut)) != nil) {
                    snapshot?.contentMode = toPreviewView.contentMode
                    snapshot?.clipsToBounds = true
                    snapshot?.layer.cornerRadius = previewViewConfig.cornerRadius
                }
                snapshot?.layoutIfNeeded()
            }, completion: { [weak self, weak snapshot] uiViewAnimatingPosition in
                snapshot?.removeFromSuperview()
                self?.meera_previewContainer?.removeFromSuperview()
            }
        )
        if ((previewViewConfig.previewTransitionOption?.contains(.fadeOut)) != nil) {
            UIView.animateKeyframes(withDuration: 0.2, delay: 0.2, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                    snapshot?.alpha = 0
                }
            }, completion: { _ in })
        }
    }
}
