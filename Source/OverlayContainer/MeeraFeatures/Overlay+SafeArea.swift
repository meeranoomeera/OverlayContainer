import UIKit

extension OverlayContainerViewController {
    func meera_addSafeAreaView(to container: UIView, color: UIColor) {
        let safeAreaView = SafeAreaBottomView()
        safeAreaView.backgroundColor = color
        container.addSubview(safeAreaView)

        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        safeAreaView.pinToSuperview(edges: [.left, .right, .bottom])

        // задержка чтобы получить значение safe area
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self, weak safeAreaView] in
            safeAreaView?.heightAnchor.constraint(equalToConstant: self?.view.safeAreaInsets.bottom ?? 0).isActive = true
        }
    }
}

