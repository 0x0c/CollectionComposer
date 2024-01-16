//
//  ListSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/04.
//

import UIKit

/// `ListSection` provides table layout like UITableView by ``UICollectionLayoutListConfiguration``
open class ListSection: Section {
    // MARK: Lifecycle

    public init(
        id: String = UUID().uuidString,
        cellStyle: CellStyle = .default,
        apperarance: UICollectionLayoutListConfiguration.Appearance = .plain,
        @ItemBuilder<any ListCellConfigurable> _ items: () -> [any ListCellConfigurable]
    ) {
        self.id = id
        self.items = items()
        self.cellStyle = cellStyle
        listConfiguration = UICollectionLayoutListConfiguration(appearance: apperarance)
        prepare()
    }

    // MARK: Open

    open var identifier: String {
        return "collection-composer-list-section-\(id)"
    }

    open var snapshotItems: [AnyHashable] {
        return items.map { AnyHashable($0) }
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        return NSCollectionLayoutSection.list(
            using: listConfiguration,
            layoutEnvironment: environment
        )
    }

    open func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell {
        if snapshotSection.hashValue == item.hashValue {
            return collectionView.dequeueConfiguredReusableCell(using: expandableHeaderRegistration, for: indexPath, item: ())
        }
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: exactItem(for: item, in: items)
        )
    }

    open func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
        default:
            return nil
        }
    }

    // MARK: Public

    public typealias Cell = UICollectionViewListCell
    public typealias Item = (any ListCellConfigurable)

    public enum CellStyle {
        case `default`
        case subtitle
        case value
        case sidebarCell
        case sidebarSubtitle
        case accompaniedSidebar
        case accompaniedSidebarSubtitle
    }

    public enum Header {
        case plain(_ text: String, isExpandable: Bool = false)
    }

    public enum Footer {
        case plain(_ text: String)
    }

    public typealias SwipeActionConfigurationProvider = (any ListCellConfigurable) -> UISwipeActionsConfiguration?

    public private(set) var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, ListCellConfigurable>!
    public private(set) var items: [any ListCellConfigurable]

    public var isExpanded = true

    public var isExpandable: Bool {
        guard let header else {
            return false
        }
        switch header {
        case let .plain(_, isExpandable):
            return isExpandable
        }
    }
    
    public func expand(_ expand: Bool) -> ListSection {
        isExpanded = expand
        return self
    }

    public func leadingSwipeActions(_ provider: @escaping SwipeActionConfigurationProvider) -> ListSection {
        leadingSwipeActionsConfigurationProvider = provider
        return self
    }

    public func trailingSwipeActions(_ provider: @escaping SwipeActionConfigurationProvider) -> ListSection {
        trailingSwipeActionsConfigurationProvider = provider
        return self
    }

    public func header(_ header: Header?) -> ListSection {
        self.header = header
        switch header {
        case let .plain(_, isExpandable):
            listConfiguration.headerMode = isExpandable ? .firstItemInSection : .supplementary
        case nil:
            listConfiguration.headerMode = .none
        }
        return self
    }

    public func footer(_ footer: Footer?) -> ListSection {
        self.footer = footer
        switch footer {
        case .plain:
            listConfiguration.footerMode = .supplementary
        case nil:
            listConfiguration.footerMode = .none
        }
        return self
    }

    // MARK: Private

    private var listConfiguration: UICollectionLayoutListConfiguration

    private let id: String
    private let cellStyle: CellStyle
    private var expandableHeaderRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Void>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    private var footerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    private var header: Header?
    private var footer: Footer?

    private var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?
    private var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider?

    private func cellConfiguration() -> UIListContentConfiguration {
        return switch cellStyle {
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

    private func headerConfiguration() -> UIListContentConfiguration {
        switch listConfiguration.appearance {
        case .grouped, .insetGrouped, .sidebar:
            return .groupedHeader()
        case .plain:
            return .plainHeader()
        case .sidebarPlain:
            return .sidebarHeader()
        @unknown default:
            return .plainHeader()
        }
    }

    private func footerConfiguration() -> UIListContentConfiguration {
        switch listConfiguration.appearance {
        case .grouped, .insetGrouped, .sidebar:
            return .groupedFooter()
        case .plain, .sidebarPlain:
            return .plainFooter()
        @unknown default:
            return .plainFooter()
        }
    }

    private func prepare() {
        cellRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell,
            any ListCellConfigurable
        > { [weak self] cell, _, item in
            guard let self else {
                return
            }
            var configuration = cellConfiguration()
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
        expandableHeaderRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Void> { [weak self] cell, _, _ in
            guard let self else {
                return
            }
            var configuration = headerConfiguration()
            switch header {
            case let .plain(text, expandable):
                configuration.text = text
                if expandable {
                    cell.accessories = [.outlineDisclosure()]
                }
            case .none:
                break
            }
            cell.contentConfiguration = configuration
        }
        headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] supplementaryView, _, _ in
            guard let self, let header else {
                return
            }
            var configuration = headerConfiguration()
            switch header {
            case let .plain(text, expandable):
                configuration.text = text
                if expandable {
                    supplementaryView.accessories = [.outlineDisclosure()]
                }
            }
            supplementaryView.contentConfiguration = configuration
        }
        footerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] supplementaryView, _, _ in
            guard let self, let footer else {
                return
            }
            var configuration = footerConfiguration()
            switch footer {
            case let .plain(text):
                configuration.text = text
            }
            supplementaryView.contentConfiguration = configuration
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
}
