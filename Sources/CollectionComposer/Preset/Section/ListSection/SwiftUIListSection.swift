//
//  SwiftUIListSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

@available(iOS 16.0, *)
open class SwiftUIListSection<View: SwiftUIListCellView>: ListableSection, HighlightableSection {
    // MARK: Lifecycle

    public init(
        id: String,
        items: [View.Model],
        appearance: UICollectionLayoutListConfiguration.Appearance = .plain,
        configuration: CellConfiguration = .default()
    ) {
        self.id = id
        self.items = items
        self.configuration = configuration
        prepare(appearance: appearance)
        listConfiguration.separatorConfiguration = configuration.separatorConfiguration
        listConfiguration.itemSeparatorHandler = { [weak self] indexPath, sectionSeparatorConfiguration in
            var configuration = sectionSeparatorConfiguration
            if self?.title != nil {
                configuration.topSeparatorInsets.trailing = max(16, sectionSeparatorConfiguration.topSeparatorInsets.trailing)
                configuration.bottomSeparatorInsets.trailing = max(16, sectionSeparatorConfiguration.topSeparatorInsets.trailing)
            }
            if let header = self?.header as? ExpandableHeader, indexPath.row == 0 {
                configuration.topSeparatorVisibility = header.topSeparatorVisibility
                configuration.bottomSeparatorVisibility = header.bottomSeparatorVisibility
            }
            return configuration
        }
    }

    // MARK: Open

    open var decorations = [Decoration]()
    open var title: String?
    open var cellRegistration: UICollectionView.CellRegistration<
        Cell,
        View.Model
    >! = UICollectionView.CellRegistration<Cell, View.Model> { cell, _, model in
        cell.configure(model)
    }

    open var items: [View.Model]
    open var isExpanded = true

    open var snapshotItems: [AnyHashable] {
        return items
    }

    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    @discardableResult
    open func indexTitle(_ title: String) -> Self {
        self.title = title
        return self
    }

    open func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?) {
        self.header = header
    }

    open func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?) {
        self.footer = footer
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection.list(
            using: listConfiguration,
            layoutEnvironment: environment
        )
        section.contentInsets = configuration.contentInsets
        return section
    }

    open func isHighlightable(at index: Int) -> Bool {
        return configuration.isHighlightable
    }

    @discardableResult
    open func expand(_ expand: Bool) -> Self {
        isExpanded = expand
        return self
    }

    // MARK: Public

    public typealias Cell = SwiftUIListCell<View>
    public typealias Item = View.Model

    public private(set) var configuration: CellConfiguration
    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public var listConfiguration: UICollectionLayoutListConfiguration!
    public var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?
    public var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?

    public var expandableHeaderRegistration: UICollectionView.CellRegistration<ExpandableHeaderListCell, Void>?
    public let id: String
}
