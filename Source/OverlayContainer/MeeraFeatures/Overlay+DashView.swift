import UIKit

public enum OverlayDashViewStyle {
	case none
	case overlay(UIColor = .clear)
	case `default`(UIColor = .white)

	public var color: UIColor? {
		switch self {
		case .none:
			return nil
		case .overlay(let color):
			return color
		case .default(let color):
			return color
		}
	}

	public var dashViewHeight: CGFloat {
		switch self {
		case .default:
			return 20
		case .overlay:
			return 20
		case .none:
			return 0
		}
	}
}

public class DashView: UIView {

	public private(set) var dragIndicator = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(dragIndicator)
		dragIndicator.translatesAutoresizingMaskIntoConstraints = false
		dragIndicator.backgroundColor = UIColor(red: 233/255, green: 235/255, blue: 236/255, alpha: 1)
		backgroundColor = .white

		NSLayoutConstraint.activate([
			dragIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			dragIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 11),
			dragIndicator.widthAnchor.constraint(equalToConstant: 80),
			dragIndicator.heightAnchor.constraint(equalToConstant: 3)
		])
		dragIndicator.layer.cornerRadius = 1.5
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func updateStyle(to style: OverlayDashViewStyle) {
		backgroundColor = style.color
	}
}
