import Foundation

public enum PreviewSizeOption {

    case fixedPreviewSize(CGSize)

    case aspectRatio(CGFloat)

    case minHorizontalInset(CGFloat)

    /// The minimum percentage of filling the entire width of the container
    case fillMinWidthRatio(CGFloat)

    /// The minimum percentage of filling the entire height of the container
    case fillMinHeightRatio(CGFloat)

    /// Fill the container by min sides with a given multiple relative to the corresponding side
    case fillByMinSide(multiply: CGFloat, W_HAspect: CGFloat)
}
