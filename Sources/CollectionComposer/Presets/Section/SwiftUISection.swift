//
//  SwiftUISection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/18.
//

import SwiftUI

// MARK: - SwiftUISection

/// A section for displaying SwiftUI content within a collection view.
///
/// `SwiftUISection` enables embedding SwiftUI views as sections in a collection view. It provides flexibility
/// for configuring content with or without margins, and supports both SwiftUI views and UI content configurations.
/// This class offers multiple initializers to accommodate different types of content and configuration needs.
///
/// ### Usage
/// ```swift
/// let swiftUISection = SwiftUISection(id: "exampleID", configuration: .defaultConfiguration()) {
///     Text("Hello, SwiftUI!")
/// }
/// ```
///
/// - Important: This class supports iOS 16.0 and later for SwiftUI-based initializers.
open class SwiftUISection: CollectionComposer.Section {
    // MARK: Lifecycle

    /// Initializes a `SwiftUISection` with a unique identifier, configuration, and view configuration item.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this section.
    ///   - configuration: The configuration options for the section. Defaults to `.defaultConfiguration()`.
    ///   - item: The view configuration for the content to be displayed in this section.
    public init(id: String, configuration: Configuration = .defaultConfiguration(), item: ViewConfiguration) {
        self.id = id
        self.configuration = configuration
        items = [item]
    }

    /// Convenience initializer that accepts a UI content configuration for the section’s content.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this section.
    ///   - configuration: The configuration options for the section. Defaults to `.defaultConfiguration()`.
    ///   - contentConfiguration: The `UIContentConfiguration` defining the section's content.
    public convenience init(id: String, configuration: Configuration = .defaultConfiguration(), contentConfiguration: UIContentConfiguration) {
        self.init(id: id, configuration: configuration, item: ViewConfiguration(contentConfiguration))
    }

    /// Convenience initializer that accepts SwiftUI content for the section’s content.
    ///
    /// This initializer allows for direct use of SwiftUI views. If the configuration specifies to remove margins,
    /// the content is displayed without margins.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this section.
    ///   - configuration: The configuration options for the section. Defaults to `.defaultConfiguration()`.
    ///   - content: A closure that returns the SwiftUI view content to be displayed in this section.
    @available(iOS 16.0, *)
    public convenience init(id: String, configuration: Configuration = .defaultConfiguration(), @ViewBuilder content: () -> some View) {
        let viewConfiguration = if configuration.removeMargins {
            ViewConfiguration(UIHostingConfiguration { content() }.margins(.all, 0))
        }
        else {
            ViewConfiguration(UIHostingConfiguration { content() })
        }
        self.init(
            id: id,
            configuration: configuration,
            item: viewConfiguration
        )
    }

    // MARK: Open

    open var decorations = [Decoration]()
    open var id: String

    open var cellRegistration: UICollectionView.CellRegistration<
        UICollectionViewCell,
        ViewConfiguration
    >! = UICollectionView.CellRegistration<UICollectionViewCell, ViewConfiguration> { cell, _, model in
        cell.contentConfiguration = model.contentConfiguration
    }

    open var items: [ViewConfiguration]
    open var isExpanded = false
    open var isExpandable = false

    open var snapshotItems: [AnyHashable] {
        return items.map { AnyHashable($0) }
    }

    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = configuration.contentInsets
        section.boundarySupplementaryItems = boundarySupplementaryItems
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    open func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?) {
        self.header = header
    }

    open func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?) {
        self.footer = footer
    }

    open func updateItems(with difference: CollectionDifference<AnyHashable>) {}

    // MARK: Public

    public struct Configuration {
        public let contentInsets: NSDirectionalEdgeInsets
        public let removeMargins: Bool

        public static func defaultConfiguration(
            contentInsets: NSDirectionalEdgeInsets = .zero,
            removeMargins: Bool = true
        ) -> Configuration {
            return Configuration(
                contentInsets: contentInsets,
                removeMargins: removeMargins
            )
        }
    }

    public struct ViewConfiguration: Hashable {
        // MARK: Lifecycle

        public init(_ contentConfiguration: UIContentConfiguration) {
            self.contentConfiguration = contentConfiguration
        }

        // MARK: Public

        public static func == (lhs: ViewConfiguration, rhs: ViewConfiguration) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        // MARK: Internal

        let id = UUID().uuidString
        var contentConfiguration: UIContentConfiguration
    }

    public typealias Cell = UICollectionViewCell
    public typealias Item = ViewConfiguration

    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public let configuration: Configuration

    public func targetIndexPathForMoveOfItemFromOriginalIndexPath(_ proposedIndexPath: IndexPath, originalIndexPath: IndexPath, currentIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.section == originalIndexPath.section {
            return proposedIndexPath
        }
        return currentIndexPath
    }
}
