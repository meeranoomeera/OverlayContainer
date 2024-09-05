import Foundation

public struct OverlayPreviewViewConfig {
    
    public init(
        previewView: PreviewItem?,
        previewSizeOption: [PreviewSizeOption]? = nil,
        previewTransitionOption: [PreviewTransitionOption]? = nil,
        distanceToContainer: CGFloat = 50
    ) {
        self.previewView = previewView
        self.previewSizeOption = previewSizeOption
        self.previewTransitionOption = previewTransitionOption
        self.distanceToContainer = distanceToContainer
    }
    
    var previewView: PreviewItem?
    var previewSizeOption: [PreviewSizeOption]?
    var previewTransitionOption: [PreviewTransitionOption]?
    var distanceToContainer: CGFloat
}
