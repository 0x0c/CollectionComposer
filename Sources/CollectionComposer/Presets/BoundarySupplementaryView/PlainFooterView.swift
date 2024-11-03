//
//  PlainFooterView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import UIKit

/// A customizable footer view that serves as a boundary supplementary footer in a collection view layout.
///
/// `PlainFooterView` is an open class that conforms to `PlainBoundaryView`, `BoundarySupplementaryFooterView`,
/// and `ListAppearanceSupplementaryView`. It allows customization of appearance, text content, and boundary
/// behavior in a list layout.
///
/// This footer view can be configured to extend beyond layout boundaries and optionally pin to visible bounds.
open class PlainFooterView: PlainBoundaryView, BoundarySupplementaryFooterView, ListAppearanceSupplementaryView {
    
    // MARK: Lifecycle

    /// Initializes a new footer view with the specified text, boundary options, and visibility settings.
    ///
    /// - Parameters:
    ///   - text: The text to display in the footer.
    ///   - pinToVisibleBounds: A Boolean indicating if the footer should pinned to bottom visible boundary of the section. Defaults to `false`.
    ///   - extendsBoundary: A Boolean indicating if the footer should extend beyond layout boundaries. Defaults to `true`.
    public init(
        _ text: String,
        pinToVisibleBounds: Bool = false,
        extendsBoundary: Bool = true
    ) {
        self.text = text
        self.pinToVisibleBounds = pinToVisibleBounds
        self.extendsBoundary = extendsBoundary
        prepare()
    }

    // MARK: Open

    /// A supplementary registration object for the footer view.
    ///
    /// This registration defines how to configure a `UICollectionViewListCell`
    /// for use as a footer in the collection view.
    open var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    /// The appearance style for the footer view in a list layout.
    ///
    /// Specifies the visual style of the footer, using predefined list appearance options.
    open var appearance: UICollectionLayoutListConfiguration.Appearance = .plain

    /// A Boolean value indicating whether the footer is expandable.
    ///
    /// By default, this property is set to `false`.
    open var isExpandable: Bool { false }

    /// The element kind for the footer, used to register and dequeue the footer in the collection view.
    ///
    /// This property is set to `UICollectionView.elementKindSectionFooter`.
    open var elementKind: String { UICollectionView.elementKindSectionFooter }

    /// The mode configuration for the footer in a list layout.
    ///
    /// This property determines the footer mode, defaulting to `.none`.
    open var footerMode: UICollectionLayoutListConfiguration.FooterMode { .none }

    /// Prepares the footer view for display by setting up its registration and configuring its content.
    ///
    /// This method is called during initialization to set up the `registration` property
    /// with the correct element kind and configuration options.
    open func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: elementKind
        ) { [weak self] supplementaryView, _, _ in
            guard let self else {
                return
            }
            var configuration = footerConfiguration()
            configuration.text = text
            supplementaryView.contentConfiguration = configuration
        }
    }

    // MARK: Public

    /// A Boolean value that determines if the footer should extend beyond the layout boundary.
    ///
    /// If `true`, the footer can render beyond the default boundaries of the collection view layout.
    public let extendsBoundary: Bool

    /// The text displayed in the footer.
    ///
    /// This text is applied to the footer's configuration during setup.
    public let text: String

    /// A Boolean value that indicates if the footer should remain pinned to visible bounds.
    ///
    /// If `true`, the footer remains visible even when scrolling.
    public let pinToVisibleBounds: Bool

    // MARK: Internal

    /// Returns a configuration object for the footer based on the appearance setting.
    ///
    /// This method generates a `UIListContentConfiguration` appropriate to the list appearance
    /// (e.g., grouped or plain).
    ///
    /// - Returns: A `UIListContentConfiguration` configured for the current appearance style.
    func footerConfiguration() -> UIListContentConfiguration {
        switch appearance {
        case .grouped, .insetGrouped, .sidebar:
            return .groupedFooter()
        case .plain, .sidebarPlain:
            return .plainFooter()
        @unknown default:
            return .plainFooter()
        }
    }
}
