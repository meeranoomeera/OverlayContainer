import UIKit

extension OverlayContainerViewController {
    public func setExternalScrollViewDelegate(
        delegate: ExternalOverlayScrollViewDelegate,
        for scrollView: UIScrollView
    ) {
        guard delegate !== self.externalScrollViewDelegate else { return }
        guard isViewLoaded else { return }
        self.externalScrollViewDelegate = delegate
        self.drivingScrollView = scrollView
        loadTranslationDrivers()
    }
	
	public func clearExternalScrollViewDelegate() {
		guard isViewLoaded else { return }
		self.externalScrollViewDelegate = nil
		self.drivingScrollView = nil
		loadTranslationDrivers()
	}
}
