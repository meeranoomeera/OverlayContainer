import Foundation

public struct OverlayPreviewViewConfig {
    
    public init(
        previewView: OverlayPreviewItem?,
        previewSizeOption: [OverlayPreviewSizeOption]? = nil,
        previewTransitionOption: [OverlayPreviewTransitionOption]? = nil,
        distanceToContainer: CGFloat = 50,
        cornerRadius: CGFloat = 0
    ) {
        self.previewView = previewView
        self.previewSizeOption = previewSizeOption
        self.previewTransitionOption = previewTransitionOption
        self.distanceToContainer = distanceToContainer
        self.cornerRadius = cornerRadius
    }
    
    var previewView: OverlayPreviewItem?
    var previewSizeOption: [OverlayPreviewSizeOption]?
    var previewTransitionOption: [OverlayPreviewTransitionOption]?
    var distanceToContainer: CGFloat
    var cornerRadius: CGFloat
}
