//
//  ListableSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/04.
//

import UIKit

// MARK: - ExpandableHeaderListCell

/// A custom collection view list cell that supports expandable header configurations.
///
/// `ExpandableHeaderListCell` is a subclass of `UICollectionViewListCell` designed
/// to work with expandable headers. It allows updating the cell's configuration based
/// on a provided `ExpandableHeader` instance and a specified expansion state.
///
/// This cell is intended for use in collection view lists where headers need to support
/// expanded and collapsed states.
///
/// - Note: This class overrides `updateConfiguration(using:)` to apply custom configurations
///         based on the cell's state.
public class ExpandableHeaderListCell: UICollectionViewListCell {
    
    // MARK: Public

    /// Updates the cell’s configuration using the specified state.
    ///
    /// This method is called whenever the cell’s state changes, such as when it is selected
    /// or highlighted. It updates the `contentConfiguration` based on the current state by
    /// calling `update(using:)` on the expandable header.
    ///
    /// - Parameter state: The current state of the cell, provided by `UICellConfigurationState`.
    override public func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        contentConfiguration = expandableHeader?.update(using: state)
    }

    // MARK: Internal

    /// Updates the expandable header and adjusts the cell's configuration.
    ///
    /// This method is called to set a new `ExpandableHeader` instance and adjust
    /// the configuration to reflect whether the header is expanded or collapsed.
    /// It updates the cell’s accessories and `contentConfiguration` based on the provided
    /// `ExpandableHeader` configuration.
    ///
    /// - Parameters:
    ///   - expandableHeader: An instance conforming to `ExpandableHeader` used to configure the cell.
    ///   - isExpanded: A Boolean indicating whether the header is in an expanded state.
    func updateExpandableHeader(_ expandableHeader: any ExpandableHeader, isExpanded: Bool) {
        self.expandableHeader = expandableHeader
        var configuration = expandableHeader.headerConfiguration(isExpanded: isExpanded)
        accessories = expandableHeader.accessories
        contentConfiguration = configuration
    }

    // MARK: Private

    /// The expandable header instance used to configure the cell.
    ///
    /// This property holds a reference to an `ExpandableHeader`, which provides
    /// the configuration details for the cell’s content and accessories.
    private var expandableHeader: (any ExpandableHeader)?
}

// MARK: - CellConfiguration

/// A configuration structure for customizing the appearance and behavior of a collection view cell.
///
/// `CellConfiguration` provides various options to define the cell's style, content insets, highlight behavior,
/// and separator visibility. It includes pre-configured methods for standard and hidden cell configurations.
public struct CellConfiguration {
    
    /// Defines various styles for a cell.
    ///
    /// These styles control the appearance and layout of the cell, providing options for default, subtitle,
    /// value display, and various sidebar styles.
    public enum CellStyle {
        /// A default cell style.
        case `default`
        /// A cell style with a subtitle layout.
        case subtitle
        /// A cell style displaying a value.
        case value
        /// A cell style suitable for sidebar display.
        case sidebarCell
        /// A cell style with a subtitle layout for sidebar display.
        case sidebarSubtitle
        /// A cell style with an accompanying element for sidebar display.
        case accompaniedSidebar
        /// A cell style with an accompanying element and subtitle for sidebar display.
        case accompaniedSidebarSubtitle
    }

    /// An option set defining edges for cell separator visibility.
    ///
    /// `SeparatorEdge` is used to specify which edges should display a separator. It includes options for
    /// top and bottom edges, as well as a combined `all` option.
    public struct SeparatorEdge: OptionSet {
        
        // MARK: Lifecycle

        /// Initializes a `SeparatorEdge` with a raw value.
        ///
        /// - Parameter rawValue: A bitmask representing the separator edge options.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: Public

        /// Displays a separator on the top edge of the cell.
        public static let top = SeparatorEdge(rawValue: 1 << 0)
        /// Displays a separator on the bottom edge of the cell.
        public static let bottom = SeparatorEdge(rawValue: 1 << 1)
        /// Displays separators on both the top and bottom edges of the cell.
        public static let all: SeparatorEdge = [.top, .bottom]

        /// The raw value representing the edge options.
        public let rawValue: UInt
    }

    /// Insets applied to the cell's content.
    ///
    /// Defines the padding around the cell's content, using directional insets.
    public let contentInsets: NSDirectionalEdgeInsets
    /// A Boolean value indicating whether the cell should highlight when selected.
    ///
    /// If `true`, the cell can be highlighted. Otherwise, it remains unhighlighted when selected.
    public let isHighlightable: Bool
    /// Configuration options for the cell's separators.
    ///
    /// Defines the visibility and appearance of the cell’s separators.
    public let separatorConfiguration: UIListSeparatorConfiguration

    /// Creates a default cell configuration with specified insets, highlightability, and separator configuration.
    ///
    /// This method provides a quick way to create a basic cell configuration with optional parameters.
    ///
    /// - Parameters:
    ///   - contentInsets: The insets for the cell content. Defaults to `.zero`.
    ///   - highlightable: A Boolean indicating if the cell is highlightable. Defaults to `false`.
    ///   - separatorConfiguration: The configuration for cell separators. Defaults to a plain list appearance.
    /// - Returns: A `CellConfiguration` with the specified parameters.
    public static func `default`(
        contentInsets: NSDirectionalEdgeInsets = .zero,
        highlightable: Bool = false,
        separatorConfiguration: UIListSeparatorConfiguration = UIListSeparatorConfiguration(listAppearance: .plain)
    ) -> CellConfiguration {
        return CellConfiguration(
            contentInsets: contentInsets,
            isHighlightable: highlightable,
            separatorConfiguration: separatorConfiguration
        )
    }

    /// Creates a cell configuration with hidden separator edges.
    ///
    /// This method allows specifying which separator edges should be hidden, with optional parameters
    /// for content insets and highlightability.
    ///
    /// - Parameters:
    ///   - hiddenEdges: The edges on which separators should be hidden. Defaults to `.all`.
    ///   - contentInsets: The insets for the cell content. Defaults to `.zero`.
    ///   - highlightable: A Boolean indicating if the cell is highlightable. Defaults to `false`.
    /// - Returns: A `CellConfiguration` with the specified hidden separator edges.
    public static func hidden(
        _ hiddenEdges: SeparatorEdge = .all,
        contentInsets: NSDirectionalEdgeInsets = .zero,
        highlightable: Bool = false
    ) -> CellConfiguration {
        var separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .plain)
        separatorConfiguration.topSeparatorVisibility = hiddenEdges.contains(.top) ? .hidden : .visible
        separatorConfiguration.bottomSeparatorVisibility = hiddenEdges.contains(.bottom) ? .hidden : .visible
        return CellConfiguration(
            contentInsets: contentInsets,
            isHighlightable: highlightable,
            separatorConfiguration: separatorConfiguration
        )
    }
}


/// An enumeration that defines the display mode for a section header in a collection view layout.
///
/// `HeaderMode` specifies whether a header should be displayed as the first item in the section,
/// as a supplementary view, or not displayed at all.
public enum HeaderMode {
    /// Displays the header as the first item in the section.
    ///
    /// In this mode, the header behaves like a regular item at the start of the section.
    case firstItemInSection
    
    /// Displays the header as a supplementary view.
    ///
    /// In this mode, the header is treated as a supplementary view, positioned independently
    /// from the section’s items.
    case supplementary
    
    /// No header is displayed for the section.
    ///
    /// This mode disables the header, making the section appear without a header view.
    case none
}

// MARK: - ListableSection

/// A protocol that defines a section in a list-based collection view layout.
///
/// `ListableSection` extends `IndexTitleSection` and represents a configurable section
/// within a list layout, supporting features like swipe actions, expandable headers,
/// and header configuration modes.
///
/// - Note: This protocol is annotated with `@MainActor`, so all methods and properties
///         are expected to be used on the main thread.
@MainActor
public protocol ListableSection: IndexTitleSection & AnyObject {
    
    /// A type alias for a provider that returns swipe action configurations.
    ///
    /// This provider takes an `Item` and returns an optional `UISwipeActionsConfiguration`
    /// that defines the actions for swiping on the item.
    typealias SwipeActionConfigurationProvider = (Item) -> UISwipeActionsConfiguration?

    /// The cell configuration for items in the section.
    ///
    /// Defines the appearance and behavior of the cells within this section.
    var configuration: CellConfiguration { get }
    
    /// The layout configuration for the list.
    ///
    /// Controls various layout options for the list, including appearance
    /// and behavior settings for the section's items.
    var listConfiguration: UICollectionLayoutListConfiguration! { get set }
    
    /// A cell registration used to configure expandable header cells.
    ///
    /// Provides a registration object that defines how to configure an
    /// `ExpandableHeaderListCell` for display in the section.
    var expandableHeaderRegistration: UICollectionView.CellRegistration<ExpandableHeaderListCell, Void>? { get set }
    
    /// A provider that supplies the leading swipe actions for the section's items.
    ///
    /// This optional closure defines actions that are displayed when the user
    /// swipes the item from the left edge.
    var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider? { get }
    
    /// A provider that supplies the trailing swipe actions for the section's items.
    ///
    /// This optional closure defines actions that are displayed when the user
    /// swipes the item from the right edge.
    var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider? { get }

    /// The display mode for the section header.
    ///
    /// Specifies how the header should be displayed, based on the `HeaderMode`
    /// enumeration, such as `firstItemInSection`, `supplementary`, or `none`.
    var headerMode: HeaderMode { get }

    /// Prepares the section with a specific appearance configuration.
    ///
    /// This method allows setting up the section’s appearance using one of
    /// the predefined `UICollectionLayoutListConfiguration.Appearance` styles.
    ///
    /// - Parameter appearance: The appearance style for the list layout.
    func prepare(appearance: UICollectionLayoutListConfiguration.Appearance)
    
    /// Returns the actual index of an item at a specified position.
    ///
    /// This method provides the actual index of an item based on the
    /// provided position, which can be useful in managing data for the section.
    ///
    /// - Parameter index: The position index to convert.
    /// - Returns: The actual index of the item.
    func actualIndex(at index: Int) -> Int
    
    /// Sets the top padding for the section header.
    ///
    /// This method allows setting or clearing a specific padding value
    /// for the header’s top edge. If the padding is set to `nil`, it uses
    /// the default padding.
    ///
    /// - Parameter padding: An optional value for the header’s top padding.
    /// - Returns: The `ListableSection` instance for chaining.
    @discardableResult
    func headerTopPadding(_ padding: CGFloat?) -> Self
}

// MARK: - ListConfiguration

public extension ListableSection {
    var isExpandable: Bool {
        guard let header,
              let header = header as? ExpandableHeader else {
            return false
        }
        return header.isExpandable
    }

    var headerMode: HeaderMode {
        switch listConfiguration.headerMode {
        case .firstItemInSection:
            return .firstItemInSection
        case .supplementary:
            return .supplementary
        case .none:
            return .none
        }
    }

    @discardableResult
    func headerTopPadding(_ padding: CGFloat?) -> Self {
        listConfiguration.headerTopPadding = padding
        return self
    }

    func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection.list(
            using: listConfiguration,
            layoutEnvironment: environment
        )
        return section
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell {
        if snapshotSection.hashValue == item.hashValue, let expandableHeaderRegistration {
            return collectionView.dequeueConfiguredReusableCell(using: expandableHeaderRegistration, for: indexPath, item: ())
        }
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: exactItem(for: item, in: items)
        )
    }

    func prepare(appearance: UICollectionLayoutListConfiguration.Appearance) {
        listConfiguration = UICollectionLayoutListConfiguration(appearance: appearance)
        expandableHeaderRegistration = UICollectionView.CellRegistration<ExpandableHeaderListCell, Void> { [weak self] cell, _, _ in
            guard let self else {
                return
            }
            if let header = header as? ExpandableHeader, header.isExpandable {
                cell.updateExpandableHeader(header, isExpanded: isExpanded)
            }
        }
        listConfiguration.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self, let provider = leadingSwipeActionsConfigurationProvider else {
                return nil
            }
            let item = items[indexPath.row]
            return provider(item)
        }
        listConfiguration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self, let provider = trailingSwipeActionsConfigurationProvider else {
                return nil
            }
            let item = items[indexPath.row]
            return provider(item)
        }
    }

    func prepareHeaderView() {
        if var header = header as? ListAppearanceSupplementaryView {
            header.appearance = listConfiguration.appearance
        }
        if let header {
            listConfiguration.headerMode = header.headerMode
        }
        else {
            listConfiguration.headerMode = .supplementary
        }
    }

    func prepareFooterView() {
        if var footer = footer as? ListAppearanceSupplementaryView {
            footer.appearance = listConfiguration.appearance
        }
        if let footer {
            listConfiguration.footerMode = footer.footerMode
        }
        else {
            listConfiguration.footerMode = .none
        }
    }

    func actualIndex(at index: Int) -> Int {
        if header is ExpandableHeader {
            return max(0, index - 1)
        }
        if listConfiguration.headerMode == .firstItemInSection {
            return max(0, index - 1)
        }
        return index
    }
}
