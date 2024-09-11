import UIKit

extension OverlayContainerViewController {
    internal func meera_setupKeyboardObserver() {
        kbObserver.observe { [weak self] event in
            guard 
                let self = self,
                let keyboardPolicy = configuration.overlayKeyboardPolicy()
            else {
                return
            }

            switch event.type {
            case .willShow:
                guard !self.isBeingDismissed else {
                    return
                }

                switch keyboardPolicy {
                case .switchToLongForm:
                    self.moveOverlay(toNotchAt: configuration.maximumNotchIndex, animated: true)
                    self.meera_keyboardHeight = -(event.keyboardFrameEnd.height)
                case let .switchToLongFormWithPinndedView(additionOffset):
                    self.moveOverlay(toNotchAt: configuration.maximumNotchIndex, animated: true)
                    self.meera_keyboardHeight = -(event.keyboardFrameEnd.height + additionOffset)
                    self.meera_finalBottomContraintValue = self.meera_keyboardHeight
                case .ignore:
                    break
                }
            case .willHide:
                if case .switchToLongFormWithPinndedView = keyboardPolicy {
                    self.meera_keyboardHeight = 0
                    self.meera_finalBottomContraintValue = self.meera_keyboardHeight
                    self.meera_updatePinnedViewConstraints(nil)
                }
            case .didHide, .didShow, .willChangeFrame, .didChangeFrame:
                break
            }
        }
    }

    internal func meera_hideKeyboardIfNeeded(forNotch index: Int) {
        guard let keyboardPolicy = configuration.overlayKeyboardPolicy() else {
            return
        }

        let shouldHide = configuration.heightForNotch(at: index) < -meera_keyboardHeight
        switch keyboardPolicy {
        case .switchToLongForm,
            .switchToLongFormWithPinndedView:
            if shouldHide { view.endEditing(true) }
        case .ignore:
            break
        }
    }
}
