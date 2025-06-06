//
//  ListSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import Foundation
import UIKit

/// `ListSection` provides table layout like UITableView by ``listConfiguration``
open class ListSection: ListableSection, HighlightableSection {
    // MARK: Lifecycle

    public convenience init(
        id: String = UUID().uuidString,
        cellStyle: CellConfiguration.CellStyle = .default,
        apperarance: UICollectionLayoutListConfiguration.Appearance = .plain,
        configuration: CellConfiguration = .default(),
        @ItemBuilder<any ListCellConfigurable> _ items: () -> [any ListCellConfigurable]
    ) {
        self.init(
            id: id,
            cellStyle: cellStyle,
            apperarance: apperarance,
            configuration: configuration,
            items: items()
        )
    }

    public init(
        id: String = UUID().uuidString,
        cellStyle: CellConfiguration.CellStyle = .default,
        apperarance: UICollectionLayoutListConfiguration.Appearance = .plain,
        configuration: CellConfiguration = .default(),
        items: [any ListCellConfigurable]
    ) {
        self.id = id
        self.items = items
        self.cellStyle = cellStyle
        self.configuration = configuration
        prepare(appearance: apperarance)
        cellRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell,
            any ListCellConfigurable
        > { [weak self] cell, _, item in
            guard let self else {
                return
            }
            var configuration = Self.cellConfiguration(for: cellStyle)
            configuration.image = item.image
            if let text = item.attributedText {
                configuration.attributedText = text
            }
            else {
                configuration.text = item.text
            }

            if let text = item.secondaryAttributedText {
                configuration.secondaryAttributedText = text
            }
            else {
                configuration.secondaryText = item.secondaryText
            }
            cell.contentConfiguration = configuration
            cell.accessories = item.accessories
            if let width = item.indentationWidth {
                cell.indentationWidth = width
            }
            if let level = item.indentationLevel {
                cell.indentationLevel = level
            }
            cell.indentsAccessories = item.indentsAccessories
        }
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

    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    open func updateItems(with difference: CollectionDifference<AnyHashable>) {
        if let newItems = snapshotItems.applying(difference) {
            items = newItems.compactMap { $0 as? Item }
        }
    }

    open func targetIndexPathForMoveOfItemFromOriginalIndexPath(_ proposedIndexPath: IndexPath, originalIndexPath: IndexPath, currentIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.section == originalIndexPath.section {
            return proposedIndexPath
        }
        return currentIndexPath
    }

    // MARK: Public

    public typealias Cell = UICollectionViewListCell
    public typealias Item = (any ListCellConfigurable)

    public var contentInsetsReference: UIContentInsetsReference?
    public var supplementaryContentInsetsReference: UIContentInsetsReference?
    public let id: String
    public private(set) var items: [any ListCellConfigurable]
    public var isExpanded = true
    public var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, any ListCellConfigurable>!
    public var title: String?

    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public private(set) var decorationItems = [NSCollectionLayoutDecorationItem]()

    public var listConfiguration: UICollectionLayoutListConfiguration!
    public var expandableHeaderRegistration: UICollectionView.CellRegistration<ExpandableHeaderListCell, Void>?
    public var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?
    public var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?

    public let configuration: CellConfiguration

    public var snapshotItems: [AnyHashable] {
        return items.map { AnyHashable($0) }
    }

    @discardableResult
    public func contentInsetsReference(_ reference: UIContentInsetsReference) -> Self {
        contentInsetsReference = reference
        return self
    }

    @discardableResult
    public func supplementaryContentInsetsReference(_ reference: UIContentInsetsReference) -> Self {
        supplementaryContentInsetsReference = reference
        return self
    }

    public func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?) {
        self.header = header
    }

    public func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?) {
        self.footer = footer
    }

    public func isHighlightable(at index: Int) -> Bool {
        if configuration.isHighlightable {
            return true
        }
        return items[actualIndex(at: index)].isHighlightable
    }

    @discardableResult
    public func indexTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    public func expand(_ expand: Bool) -> Self {
        isExpanded = expand
        return self
    }

    @discardableResult
    public func leadingSwipeActions(_ provider: @escaping SwipeActionConfigurationProvider) -> Self {
        leadingSwipeActionsConfigurationProvider = provider
        return self
    }

    @discardableResult
    public func trailingSwipeActions(_ provider: @escaping SwipeActionConfigurationProvider) -> Self {
        trailingSwipeActionsConfigurationProvider = provider
        return self
    }

    // MARK: Private

    private let cellStyle: CellConfiguration.CellStyle

    private static func cellConfiguration(for style: CellConfiguration.CellStyle) -> UIListContentConfiguration {
        return switch style {
        case .default:
            .cell()
        case .subtitle:
            .subtitleCell()
        case .value:
            .valueCell()
        case .sidebarCell:
            .accompaniedSidebarCell()
        case .sidebarSubtitle:
            .sidebarSubtitleCell()
        case .accompaniedSidebar:
            .accompaniedSidebarCell()
        case .accompaniedSidebarSubtitle:
            .accompaniedSidebarSubtitleCell()
        }
    }
}
