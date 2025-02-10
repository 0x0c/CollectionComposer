//
//  PlainHeaderView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/20.
//

import UIKit

/// A customizable header view that serves as a boundary supplementary header in a collection view layout.
///
/// `PlainHeaderView` is an open class that conforms to `PlainBoundaryHeaderView`, `BoundarySupplementaryHeaderView`,
/// and `ListAppearanceSupplementaryView`. It provides configuration options for text content, expansion behavior,
/// and boundary settings in a list-based layout.
///
/// This header view can be set to extend beyond layout boundaries, pin to visible bounds, and support expandable headers.
open class PlainHeaderView: PlainBoundaryHeaderView, BoundarySupplementaryHeaderView, ListAppearanceSupplementaryView {
    // MARK: Lifecycle

    /// Initializes a new header view with the specified text, boundary, and visibility settings.
    ///
    /// - Parameters:
    ///   - text: The text to display in the header.
    ///   - pinToVisibleBounds: A Boolean indicating if the header should pinned to top visible boundary of the section. Defaults to `true`.
    ///   - isExpandable: A Boolean indicating if the header is expandable. Defaults to `false`.
    ///   - extendsBoundary: A Boolean indicating if the header should extend beyond layout boundaries. Defaults to `true`.
    public init(
        _ text: String,
        pinToVisibleBounds: Bool = true,
        isExpandable: Bool = false,
        extendsBoundary: Bool = true
    ) {
        self.text = text
        self.pinToVisibleBounds = pinToVisibleBounds
        self.isExpandable = isExpandable
        self.extendsBoundary = extendsBoundary
        prepare()
    }

    // MARK: Open

    /// A supplementary registration object for the header view.
    ///
    /// This registration defines how to configure a `UICollectionViewListCell`
    /// for use as a header in the collection view.
    open var registration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    /// A Boolean indicating whether the header is expanded.
    ///
    /// This property reflects the current expansion state of the header.
    open var isExpanded: Bool = false

    /// The appearance style for the header view in a list layout.
    ///
    /// Specifies the visual style of the header, using predefined list appearance options.
    open var appearance: UICollectionLayoutListConfiguration.Appearance = .plain

    /// The mode configuration for the header in a list layout.
    ///
    /// Specifies the header mode, defaulting to `.firstItemInSection` if the header is expandable, otherwise `.supplementary`.
    open var headerMode: UICollectionLayoutListConfiguration.HeaderMode { isExpandable ? .firstItemInSection : .supplementary }

    /// The element kind for the header, used to register and dequeue the header in the collection view.
    ///
    /// This property is set to `UICollectionView.elementKindSectionHeader`.
    open var elementKind: String { UICollectionView.elementKindSectionHeader }

    /// The accessories to display in the header, including an outline disclosure indicator.
    ///
    /// This accessory is shown if the header is expandable.
    open var accessories: [UICellAccessory] { [.outlineDisclosure()] }

    /// Prepares the header view for display by setting up its registration and configuring its content.
    ///
    /// This method is called during initialization to set up the `registration` property with the correct
    /// element kind and configuration options.
    open func prepare() {
        registration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: elementKind
        ) { [weak self] supplementaryView, _, _ in
            guard let self else {
                return
            }
            var configuration = headerConfiguration(isExpanded: isExpanded) as! UIListContentConfiguration
            configuration.text = text
            if isExpandable {
                supplementaryView.accessories = [.outlineDisclosure()]
            }
            supplementaryView.contentConfiguration = configuration
        }
    }

    // MARK: Public

    /// A Boolean value that determines if the header should extend beyond the layout boundary.
    ///
    /// If `true`, the header can render beyond the default boundaries of the collection view layout.
    public let extendsBoundary: Bool

    /// The text displayed in the header.
    ///
    /// This text is applied to the header's configuration during setup.
    public let text: String

    /// A Boolean value that indicates if the header should remain pinned to visible bounds.
    ///
    /// If `true`, the header remains visible even when scrolling.
    public let pinToVisibleBounds: Bool

    /// A Boolean value indicating if the header supports an expandable configuration.
    ///
    /// If `true`, the header can be expanded or collapsed, with the expansion state managed by the collection view.
    public let isExpandable: Bool

    /// Returns a configuration object for the header based on the appearance and expansion state.
    ///
    /// This method generates a `UIListContentConfiguration` appropriate to the list appearance and expansion state.
    ///
    /// - Parameter isExpanded: A Boolean indicating if the header is in an expanded state.
    /// - Returns: A `UIListContentConfiguration` configured for the current appearance and expansion state.
    public func headerConfiguration(isExpanded: Bool) -> (any UIContentConfiguration)? {
        var configuration: UIListContentConfiguration = {
            switch appearance {
            case .grouped, .insetGrouped, .sidebar:
                return .groupedHeader()
            case .plain:
                return .plainHeader()
            case .sidebarPlain:
                return .sidebarHeader()
            @unknown default:
                return .plainHeader()
            }
        }()
        configuration.text = text
        return configuration
    }

    /// Updates the header view configuration based on the cell's current state.
    ///
    /// This method allows dynamically updating the header configuration in response to
    /// changes in the cell state, such as when expanded.
    ///
    /// - Parameter state: The current configuration state of the cell.
    /// - Returns: A `UIContentConfiguration` for the header based on the state.
    public func update(using state: UICellConfigurationState) -> (any UIContentConfiguration)? {
        return headerConfiguration(isExpanded: state.isExpanded)
    }
}
