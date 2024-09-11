import UIKit

extension OverlayContainerViewController {
    public func setContentMaxHeight(_ value: CGFloat?, animated: Bool) {
        contentMaxHeightConstraint?.constant = value ?? UIScreen.main.bounds.height + 100
        contentMaxHeightConstraint?.isActive = true

        if animated {
            baseAnimation { [weak self] in
                self?.overlayContainerView.layoutIfNeeded()
            }
        }
    }

    public func changeSideInsets(
        left: CGFloat,
        right: CGFloat,
        animated: Bool
    ) {
        leftInsetConstraint?.constant = -left
        rightInsetConstraint?.constant = right
        leftInsetConstraint?.isActive = true
        rightInsetConstraint?.isActive = true


        if animated {
            baseAnimation { [weak self] in
                self?.overlayTranslationView.layoutIfNeeded()
                self?.dashView.frame.origin.x = -left
            }
        } else {
            dashView.frame.origin.x = -left
        }
    }

    public func setContentHeight(
        height: CGFloat,
        animated: Bool
    ) {
        overlayContainerViewStyleConstraint?.constant = height
        overlayContainerViewStyleConstraint?.isActive = true

        if animated {
            baseAnimation { [weak self] in
                self?.overlayTranslationView.layoutIfNeeded()
            }
        }
    }

    public func setTopInset(_ value: CGFloat, animated: Bool) {
        topInsetValue = value
        meera_topConstraint?.constant = value
        meera_topConstraint?.isActive = true

        if animated {
            baseAnimation { [weak self] in
                self?.dashView.frame.size.height = value + 1
                self?.overlayTranslationView.layoutIfNeeded()
            }
        } else {
            dashView.frame.size.height = value + 1
        }

        updateOverlayContainerConstraints()
    }
}
