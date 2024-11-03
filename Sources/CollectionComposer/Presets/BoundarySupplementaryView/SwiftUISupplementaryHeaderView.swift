//
//  SwiftUISupllementaryHeaderView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/11.
//

import SwiftUI
import UIKit

/// A header view that integrates SwiftUI content within a collection view layout.
///
/// `SwiftUISupplementaryHeaderView` is an open class that conforms to `SwiftUISupplementaryView`
/// and `BoundarySupplementaryHeaderView`, allowing the use of SwiftUI content in collection view
/// headers. It provides customizable options for visibility, layout boundaries, offsets, and content configuration.
open class SwiftUISupplementaryHeaderView<T: UICollectionViewCell>: SwiftUISupplementaryView, BoundarySupplementaryHeaderView {
    
    // MARK: Lifecycle

    /// Initializes a new header view with a SwiftUI content builder, available on iOS 16.0 and later.
    ///
    /// This initializer allows you to use SwiftUI views within the header, with options to
    /// remove default margins and customize visibility settings.
    ///
    /// - Parameters:
    ///   - elementKind: The element kind of the header.
    ///   - pinToVisibleBounds: A Boolean indicating if the header should pinned to top visible boundary of the section. Defaults to `false`.
    ///   - absoluteOffset: The offset for positioning the header. Defaults to `.zero`.
    ///   - removeMargins: A Boolean indicating if the default margins should be removed. Defaults to `true`.
    ///   - extendsBoundary: A Boolean indicating if the header should extend beyond layout boundaries. Defaults to `true`.
    ///   - content: A closure that provides the SwiftUI view content for the header.
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

    /// Initializes a new header view with a UI content configuration.
    ///
    /// This initializer allows you to specify a content configuration object directly for the header.
    ///
    /// - Parameters:
    ///   - elementKind: The element kind of the header.
    ///   - pinToVisibleBounds: A Boolean indicating if the header should pinned to top visible boundary of the section. Defaults to `false`.
    ///   - absoluteOffset: The offset for positioning the header. Defaults to `.zero`.
    ///   - extendsBoundary: A Boolean indicating if the header should extend beyond layout boundaries. Defaults to `true`.
    ///   - configuration: An optional `UIContentConfiguration` for the header content.
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

    /// A supplementary registration object for the header view.
    ///
    /// This registration defines how to configure a cell of type `T` for use as a header in the collection view.
    open var registration: UICollectionView.SupplementaryRegistration<T>!

    /// The configuration object for the header content.
    ///
    /// This property stores the content configuration, which can be a custom configuration or a SwiftUI-based configuration.
    open var configuration: UIContentConfiguration?

    /// The mode configuration for the header in a list layout.
    ///
    /// This property is set to `.supplementary`, indicating the header should be treated as a supplementary view.
    open var headerMode: UICollectionLayoutListConfiguration.HeaderMode { .supplementary }

    /// Prepares the header view for display by setting up its registration and configuring its content.
    ///
    /// This method sets up the `registration` property with the specified `elementKind`
    /// and applies the content configuration to the header view.
    open func prepare() {
        registration = UICollectionView.SupplementaryRegistration<T>(elementKind: elementKind) {
            supplementaryView, _, _ in
            supplementaryView.contentConfiguration = self.configuration
        }
    }

    // MARK: Public

    /// The type of content view associated with the header.
    ///
    /// This type alias allows customization of the header cell type.
    public typealias ContentView = T

    /// A Boolean value that determines if the header should extend beyond the layout boundary.
    ///
    /// If `true`, the header can render beyond the default boundaries of the collection view layout.
    public let extendsBoundary: Bool

    /// A Boolean value that indicates if the header should remain pinned to visible bounds.
    ///
    /// If `true`, the header remains visible even when scrolling.
    public let pinToVisibleBounds: Bool

    /// The element kind for the header, used to register and dequeue the header in the collection view.
    public let elementKind: String

    /// The offset for positioning the header view.
    ///
    /// This offset is applied to the header's position within the collection view.
    public let absoluteOffset: CGPoint
}
