import Foundation

public struct OverlayPreviewViewConfig {
    
    public init(
        previewView: OverlayPreviewItem?,
        previewSizeOption: [OverlayPreviewSizeOption]? = nil,
        previewTransitionOption: [OverlayPreviewTransitionOption]? = nil,
        distanceToContainer: CGFloat = 50
    ) {
        self.previewView = previewView
        self.previewSizeOption = previewSizeOption
        self.previewTransitionOption = previewTransitionOption
        self.distanceToContainer = distanceToContainer
    }
    
    var previewView: OverlayPreviewItem?
    var previewSizeOption: [OverlayPreviewSizeOption]?
    var previewTransitionOption: [OverlayPreviewTransitionOption]?
    var distanceToContainer: CGFloat
}
