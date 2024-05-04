//
//  ListableSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/04.
//

import UIKit

// MARK: - ListableSection

public protocol ListableSection: IndexTitleSection & AnyObject {
    typealias SwipeActionConfigurationProvider = (Item) -> UISwipeActionsConfiguration?

    static func cellConfiguration(for style: ListConfiguration.CellStyle) -> UIListContentConfiguration
    static func headerConfiguration(for appearance: UICollectionLayoutListConfiguration.Appearance) -> UIListContentConfiguration
    static func footerConfiguration(for appearance: UICollectionLayoutListConfiguration.Appearance) -> UIListContentConfiguration

    var listConfiguration: UICollectionLayoutListConfiguration! { get set }
    var expandableHeaderRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Void>! { get set }
    var headerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>! { get set }
    var footerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>! { get set }

    var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider? { get }
    var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider? { get }

    var header: ListConfiguration.Header? { get set }
    var footer: ListConfiguration.Footer? { get set }

    func header(_ header: ListConfiguration.Header?) -> Self
    func footer(_ footer: ListConfiguration.Footer?) -> Self

    func prepare(appearance: UICollectionLayoutListConfiguration.Appearance)
}

// MARK: - ListConfiguration

public enum ListConfiguration {
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
}

public extension ListableSection {
    var isExpandable: Bool {
        guard let header else {
            return false
        }
        switch header {
        case let .plain(_, isExpandable):
            return isExpandable
        }
    }

    static func cellConfiguration(for style: ListConfiguration.CellStyle) -> UIListContentConfiguration {
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

    static func headerConfiguration(for appearance: UICollectionLayoutListConfiguration.Appearance) -> UIListContentConfiguration {
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
    }

    static func footerConfiguration(for appearance: UICollectionLayoutListConfiguration.Appearance) -> UIListContentConfiguration {
        switch appearance {
        case .grouped, .insetGrouped, .sidebar:
            return .groupedFooter()
        case .plain, .sidebarPlain:
            return .plainFooter()
        @unknown default:
            return .plainFooter()
        }
    }

    func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        return NSCollectionLayoutSection.list(
            using: listConfiguration,
            layoutEnvironment: environment
        )
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, item: AnyHashable) -> UICollectionViewCell {
        if snapshotSection.hashValue == item.hashValue {
            return collectionView.dequeueConfiguredReusableCell(using: expandableHeaderRegistration, for: indexPath, item: ())
        }
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: exactItem(for: item, in: items)
        )
    }

    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
        default:
            return nil
        }
    }

    func header(_ header: ListConfiguration.Header?) -> Self {
        self.header = header
        switch header {
        case let .plain(_, isExpandable):
            listConfiguration.headerMode = isExpandable ? .firstItemInSection : .supplementary
        case nil:
            listConfiguration.headerMode = .none
        }
        return self
    }

    func footer(_ footer: ListConfiguration.Footer?) -> Self {
        self.footer = footer
        switch footer {
        case .plain:
            listConfiguration.footerMode = .supplementary
        case nil:
            listConfiguration.footerMode = .none
        }
        return self
    }

    func prepare(appearance: UICollectionLayoutListConfiguration.Appearance) {
        listConfiguration = UICollectionLayoutListConfiguration(appearance: appearance)
        expandableHeaderRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Void> { [weak self] cell, _, _ in
            guard let self else {
                return
            }
            var configuration = Self.headerConfiguration(for: appearance)
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
            var configuration = Self.headerConfiguration(for: appearance)
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
            var configuration = Self.footerConfiguration(for: appearance)
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
