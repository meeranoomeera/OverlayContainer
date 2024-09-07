import UIKit

class SafeAreaBottomView: UIView {}

extension OverlayContainerViewController {

    public func meera_invalidatePinnedView() {
        guard isViewLoaded else { return }
        if let meera_pinnedViewContainer {
            meera_pinnedViewContainer.removeFromSuperview()
        }

        meera_loadOverlayPinnedView()
    }

    internal func meera_loadOverlayPinnedView() {
        guard let pinnedViewConfig = configuration.overlayPinnedViewConfig(),
              let _pinnedView = pinnedViewConfig.pinnedView else {
            return
        }

        let pinnedViewContainer = PassThroughView()
        overlayTranslationContainerView.addSubview(pinnedViewContainer)
        pinnedViewContainer.pinToSuperview(with: .zero , edges: [.left, .right, .top])

        meera_pinnedViewBottomConstraint = pinnedViewContainer.bottomAnchor.constraint(
            equalTo: overlayTranslationContainerView.bottomAnchor
        )
        meera_pinnedViewBottomConstraint?.isActive = true

        self.meera_pinnedViewContainer = pinnedViewContainer

        switch pinnedViewConfig.safeAreaPolicy {
        case .ignore, .fill:
            switch pinnedViewConfig.constraintsMode {
            case .set(let insets, let edges, let height, let width):
                pinnedViewContainer.addSubview(_pinnedView)
                // TODO: возможно это стоит поменять
                _pinnedView.frame.origin = .init(x: 0, y: UIScreen.main.bounds.height)
                _pinnedView.translatesAutoresizingMaskIntoConstraints = false
                _pinnedView.pinToSuperview(with: insets, edges: edges)
                if let height {
                    _pinnedView.heightAnchor.constraint(equalToConstant: height).isActive = true
                }
                if let width {
                    _pinnedView.widthAnchor.constraint(equalToConstant: width).isActive = true
                }
            case .getExisting:
                // задержка чтобы получить parent у pinnedView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.adjustPinnedIfNeeded(
                        pinnedView: _pinnedView,
                        container: pinnedViewContainer,
                        pinBottomToSafeArea: false
                    )
                }
            }

        case .fillAndConstrain:
            switch pinnedViewConfig.constraintsMode {
            case .set(let insets, let edges, let height, let width):
                pinnedViewContainer.addSubview(_pinnedView)
                // TODO: возможно это стоит поменять
                _pinnedView.frame.origin = .init(x: 0, y: UIScreen.main.bounds.height)
                _pinnedView.translatesAutoresizingMaskIntoConstraints = false
                _pinnedView.pinToSuperview(with: insets, edges: edges)
                if let height {
                    _pinnedView.heightAnchor.constraint(equalToConstant: height).isActive = true
                }
                if let width {
                    _pinnedView.widthAnchor.constraint(equalToConstant: width).isActive = true
                }
                _pinnedView.bottomAnchor.constraint(
                    equalTo: pinnedViewContainer.safeAreaLayoutGuide.bottomAnchor,
                    constant: insets.bottom
                ).isActive = true
            case .getExisting:
                // задержка чтобы получить parent у pinnedView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.adjustPinnedIfNeeded(
                        pinnedView: _pinnedView,
                        container: pinnedViewContainer,
                        pinBottomToSafeArea: true
                    )
                }
            }

        }

        switch pinnedViewConfig.safeAreaPolicy {
        case .fill(let color), .fillAndConstrain(let color):
            meera_addSafeAreaView(to: pinnedViewContainer, color: color)
            meera_addSafeAreaView(to: pinnedViewContainer, color: color)
        case .ignore:
            break
        }
    }

    internal func meera_updatePinnedViewConstraints(_ context: OverlayContainerTransitionCoordinatorContext?) {
        guard let pinnedViewConfig = configuration.overlayPinnedViewConfig() else {
            return
        }

        guard let context else {
            baseAnimation { [weak self] in
                guard let self else { return }
                self.meera_pinnedViewBottomConstraint?.constant = self.meera_finalBottomContraintValue
                self.meera_pinnedViewBottomConstraint?.isActive = true
                self.meera_pinnedViewContainer?.layoutIfNeeded()
            }
            return
        }

        var minHeight = context.minimumHeight()
        if let heightToStartMoveDown = pinnedViewConfig.heightToStartMoveDown {
            minHeight = heightToStartMoveDown
        }
        let diff = context.overlayTranslationHeight - (minHeight + -meera_finalBottomContraintValue) - meera_keyboardHeight // если будут проблемы иначе хэндлить высоту клавиатуры
        /*
         debugPrint("\n")
         debugPrint("context.overlayTranslationHeight \(context.overlayTranslationHeight)")
         debugPrint("context.minimumHeight \(minHeight)")
         debugPrint("finalBottomContraintValue) \(finalBottomContraintValue)")
         debugPrint("minHeight + -finalBottomContraintValue \(minHeight + -finalBottomContraintValue)")
         debugPrint("diff \(diff)")
         */
        if diff < 0 {
            meera_pinnedViewBottomConstraint?.constant = meera_finalBottomContraintValue - diff
            meera_pinnedViewBottomConstraint?.isActive = true
        }
    }

    private func adjustPinnedIfNeeded(pinnedView: UIView, container: UIView, pinBottomToSafeArea: Bool) {
        guard let pinnedParent = pinnedView.superview else {
            return
        }

        let pinnedConstraints = pinnedParent.constraints.filter({
            $0.firstItem as? UIView == pinnedView
        })

        var newConstraints: [NSLayoutConstraint] = pinnedConstraints.map({
            let constraint = NSLayoutConstraint(
                item: $0.firstItem as Any,
                attribute: $0.firstAttribute,
                relatedBy: $0.relation,
                toItem: pinBottomToSafeArea && $0.firstAttribute == .bottom
                ? container.safeAreaLayoutGuide
                : container,
                attribute: $0.secondAttribute,
                multiplier: $0.multiplier,
                constant: $0.constant
            )
            if constraint.firstAttribute == .bottom {
                self.meera_pinnedViewBottomConstraint = constraint
                constraint.priority = .defaultHigh
            }
            return constraint
        })

        newConstraints.append(
            .init(
                item: pinnedView,
                attribute: .top,
                relatedBy: .greaterThanOrEqual,
                toItem: container,
                attribute: .top,
                multiplier: 1,
                constant: 0
            ))

        pinnedView.removeFromSuperview()
        container.addSubview(pinnedView)
        NSLayoutConstraint.activate(newConstraints)
    }
}
