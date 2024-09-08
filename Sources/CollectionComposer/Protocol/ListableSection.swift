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

    var listConfiguration: UICollectionLayoutListConfiguration! { get set }
    var expandableHeaderRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Void>? { get set }
    var leadingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider? { get }
    var trailingSwipeActionsConfigurationProvider: SwipeActionConfigurationProvider? { get }

    func prepare(appearance: UICollectionLayoutListConfiguration.Appearance)
    func actualIndex(at index: Int) -> Int
    @discardableResult
    @available(iOS 15.0, *)
    func headerTopPadding(_ padding: CGFloat?) -> Self
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
}

public extension ListableSection {
    var isExpandable: Bool {
        guard let header,
              let header = header as? PlainHeaderView else {
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
    @available(iOS 15.0, *)
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
        expandableHeaderRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Void> { [weak self] cell, _, _ in
            guard let self else {
                return
            }
            if let header = header as? PlainHeaderView, header.isExpandable {
                var configuration = PlainHeaderView.headerConfiguration(for: appearance)
                cell.accessories = [.outlineDisclosure()]
                configuration.text = header.text
                cell.contentConfiguration = configuration
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
        if let header = header as? PlainHeaderView {
            header.appearance = listConfiguration.appearance
        }
        listConfiguration.headerMode = isExpandable ? .firstItemInSection : .supplementary
    }

    func prepareFooterView() {
        if let footer = footer as? PlainFooterView {
            footer.appearance = listConfiguration.appearance
        }
        listConfiguration.footerMode = .supplementary
    }

    func actualIndex(at index: Int) -> Int {
        if listConfiguration.headerMode == .firstItemInSection {
            return max(0, index - 1)
        }
        return index
    }
}
