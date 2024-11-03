//
//  SwiftUISupllementaryFooterView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import SwiftUI
import UIKit

/// A footer view that integrates SwiftUI content within a collection view layout.
///
/// `SwiftUISupplementaryFooterView` is an open class that conforms to `SwiftUISupplementaryView`
/// and `BoundarySupplementaryFooterView`, allowing the use of SwiftUI content in collection view
/// footers. It provides customizable options for visibility, layout boundaries, offsets, and content configuration.
open class SwiftUISupplementaryFooterView<T: UICollectionViewCell>: SwiftUISupplementaryView, BoundarySupplementaryFooterView {
    
    // MARK: Lifecycle

    /// Initializes a new footer view with a SwiftUI content builder, available on iOS 16.0 and later.
    ///
    /// This initializer allows you to use SwiftUI views within the footer, with options to
    /// remove default margins and customize visibility settings.
    ///
    /// - Parameters:
    ///   - elementKind: The element kind of the footer.
    ///   - pinToVisibleBounds: A Boolean indicating if the footer should pinned to bottom visible boundary of the section. Defaults to `false`.
    ///   - absoluteOffset: The offset for positioning the footer. Defaults to `.zero`.
    ///   - removeMargins: A Boolean indicating if the default margins should be removed. Defaults to `true`.
    ///   - extendsBoundary: A Boolean indicating if the footer should extend beyond layout boundaries. Defaults to `true`.
    ///   - content: A closure that provides the SwiftUI view content for the footer.
    @available(iOS 16.0, *)
    public required init(
        elementKind: String,
        pinToVisibleBounds: Bool = false,
        absoluteOffset: CGPoint = .zero,
        removeMargins: Bool = true,
        extendsBoundary: Bool = true,
        @ViewBuilder content: () -> some View
    ) {
        self.elementKind = elementKind
        self.absoluteOffset = absoluteOffset
        self.pinToVisibleBounds = pinToVisibleBounds
        self.extendsBoundary = extendsBoundary
        configuration = if removeMargins {
            UIHostingConfiguration { content() }.margins(.all, 0)
        }
        else {
            UIHostingConfiguration { content() }
        }
        prepare()
    }

    /// Initializes a new footer view with a UI content configuration.
    ///
    /// This initializer allows you to specify a content configuration object directly for the footer.
    ///
    /// - Parameters:
    ///   - elementKind: The element kind of the footer.
    ///   - pinToVisibleBounds: A Boolean indicating if the footer should pinned to bottom visible boundary of the section. Defaults to `false`.
    ///   - absoluteOffset: The offset for positioning the footer. Defaults to `.zero`.
    ///   - extendsBoundary: A Boolean indicating if the footer should extend beyond layout boundaries. Defaults to `true`.
    ///   - configuration: An optional `UIContentConfiguration` for the footer content.
    public required init(
        elementKind: String,
        pinToVisibleBounds: Bool = false,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool = true,
        configuration: (any UIContentConfiguration)? = nil
    ) {
        self.elementKind = elementKind
        self.absoluteOffset = absoluteOffset
        self.configuration = configuration
        self.pinToVisibleBounds = pinToVisibleBounds
        self.extendsBoundary = extendsBoundary
        prepare()
    }

    // MARK: Open

    /// The mode configuration for the footer in a list layout.
    ///
    /// This property is set to `.supplementary`, indicating the footer should be treated as a supplementary view.
    open var footerMode: UICollectionLayoutListConfiguration.FooterMode { .supplementary }

    // MARK: Public

    /// The type of content view associated with the footer.
    ///
    /// This type alias allows customization of the footer cell type.
    public typealias ContentView = T

    /// A Boolean value that determines if the footer should extend beyond the layout boundary.
    ///
    /// If `true`, the footer can render beyond the default boundaries of the collection view layout.
    public let extendsBoundary: Bool

    /// A supplementary registration object for the footer view.
    ///
    /// This registration defines how to configure a cell of type `T` for use as a footer in the collection view.
    public var registration: UICollectionView.SupplementaryRegistration<T>!

    /// A Boolean value that indicates if the footer should remain pinned to visible bounds.
    ///
    /// If `true`, the footer remains visible even when scrolling.
    public let pinToVisibleBounds: Bool

    /// The element kind for the footer, used to register and dequeue the footer in the collection view.
    public let elementKind: String

    /// The offset for positioning the footer view.
    ///
    /// This offset is applied to the footer's position within the collection view.
    public let absoluteOffset: CGPoint

    /// The configuration object for the footer content.
    ///
    /// This property stores the content configuration, which can be a custom configuration or a SwiftUI-based configuration.
    public var configuration: UIContentConfiguration?

    /// Prepares the footer view for display by setting up its registration and configuring its content.
    ///
    /// This method sets up the `registration` property with the specified `elementKind`
    /// and applies the content configuration to the footer view.
    public func prepare() {
        registration = UICollectionView.SupplementaryRegistration<T>(elementKind: elementKind) {
            supplementaryView, _, _ in
            supplementaryView.contentConfiguration = self.configuration
        }
    }
}
