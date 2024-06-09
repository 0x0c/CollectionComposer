//
//  ListSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import Foundation
import UIKit

/// `ListSection` provides table layout like UITableView by ``UICollectionLayoutListConfiguration``
open class ListSection: ListableSection, HighlightableSection {
    // MARK: Lifecycle

    public convenience init(
        id: String = UUID().uuidString,
        cellStyle: ListConfiguration.CellStyle = .default,
        apperarance: UICollectionLayoutListConfiguration.Appearance = .plain,
        isHighlightable: Bool = false,
        @ItemBuilder<any ListCellConfigurable> _ items: () -> [any ListCellConfigurable]
    ) {
        self.init(id: id, cellStyle: cellStyle, apperarance: apperarance, isHighlightable: isHighlightable, items: items())
    }

    public init(
        id: String = UUID().uuidString,
        cellStyle: ListConfiguration.CellStyle = .default,
        apperarance: UICollectionLayoutListConfiguration.Appearance = .plain,
        isHighlightable: Bool = false,
        items: [any ListCellConfigurable]
    ) {
        self.id = id
        self.items = items
        self.cellStyle = cellStyle
        self.isHighlightable = isHighlightable
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
            if let accessories = item.accessories {
                cell.accessories = accessories
            }
        }
        prepare(appearance: apperarance)
    }

    // MARK: Open

    open var decorations = [Decoration]()

    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    // MARK: Public

    public typealias Cell = UICollectionViewListCell
    public typealias Item = (any ListCellConfigurable)

    public let id: String
    public private(set) var items: [any ListCellConfigurable]
    public var isHighlightable: Bool
    public var isExpanded = true
    public var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, any ListCellConfigurable>!
    public var title: String?

    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public private(set) var decorationItems = [NSCollectionLayoutDecorationItem]()

    public var listConfiguration: UICollectionLayoutListConfiguration!
    public var expandableHeaderRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Void>?
    public var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?
    public var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?

    public var snapshotItems: [AnyHashable] {
        return items.map { AnyHashable($0) }
    }

    public func storeHeader(_ header: any BoundarySupplementaryHeaderView) {
        self.header = header
    }

    public func storeFooter(_ footer: any BoundarySupplementaryFooterView) {
        self.footer = footer
    }

    public func isHighlightable(at index: Int) -> Bool {
        if isHighlightable {
            return true
        }
        return items[actualIndex(at: index)].isHighlightable
    }

    public func indexTitle(_ title: String) -> Self {
        self.title = title
        return self
    }

    public func expand(_ expand: Bool) -> Self {
        isExpanded = expand
        return self
    }

    public func leadingSwipeActions(_ provider: @escaping SwipeActionConfigurationProvider) -> Self {
        leadingSwipeActionsConfigurationProvider = provider
        return self
    }

    public func trailingSwipeActions(_ provider: @escaping SwipeActionConfigurationProvider) -> Self {
        trailingSwipeActionsConfigurationProvider = provider
        return self
    }

    // MARK: Private

    private let cellStyle: ListConfiguration.CellStyle

    private static func cellConfiguration(for style: ListConfiguration.CellStyle) -> UIListContentConfiguration {
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
