//
//  SwiftUICellSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

@available(iOS 16.0, *)
open class SwiftUICellSection<View: SwiftUICellView>: CollectionComposer.Section {
    // MARK: Lifecycle

    public init(id: String, items: [View.Model], configuration: Configuration = .defaultConfiguration()) {
        self.id = id
        self.items = items
        self.configuration = configuration
    }

    // MARK: Open

    open var id: String

    open var cellRegistration: UICollectionView.CellRegistration<
        Cell,
        View.Model
    >! = UICollectionView.CellRegistration<Cell, View.Model> { cell, _, model in
        cell.configure(model)
    }

    open var items: [View.Model]
    open var isExpanded = false
    open var isExpandable = false

    open var snapshotItems: [AnyHashable] {
        return items
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize,
            supplementaryItems: configuration.showsCellSeparator ? [SeparatorView.cellSeparator()] : []
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = configuration.showsSectionSeparator ? [SeparatorView.sectionSeparator()] : []
        section.supplementariesFollowContentInsets = false
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return configuration.isHighlightable
    }

    // MARK: Public

    public struct Configuration {
        public let isHighlightable: Bool
        public let showsCellSeparator: Bool
        public let showsSectionSeparator: Bool

        public static func defaultConfiguration(highlightable: Bool = false) -> Configuration {
            return Configuration(isHighlightable: highlightable, showsCellSeparator: false, showsSectionSeparator: false)
        }

        public static func separators(highlightable: Bool = false) -> Configuration {
            return Configuration(isHighlightable: highlightable, showsCellSeparator: true, showsSectionSeparator: true)
        }

        public static func cellSeparator(highlightable: Bool = false) -> Configuration {
            return Configuration(isHighlightable: highlightable, showsCellSeparator: true, showsSectionSeparator: false)
        }

        public static func sectionSeparator(highlightable: Bool = false) -> Configuration {
            return Configuration(isHighlightable: highlightable, showsCellSeparator: false, showsSectionSeparator: true)
        }
    }

    public typealias Cell = SwiftUICell<View>
    public typealias Item = View.Model

    public func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        switch kind {
        case SeparatorView.cellSeparatorElementKind:
            return collectionView.dequeueConfiguredReusableSupplementary(using: cellSeparatorRegistration, for: indexPath)
        case SeparatorView.sectionSeparatorElementKind:
            return collectionView.dequeueConfiguredReusableSupplementary(using: sectionSeparatorRegistration, for: indexPath)
        default:
            return nil
        }
        return nil
    }

    // MARK: Internal

    var cellSeparatorRegistration = UICollectionView.SupplementaryRegistration<SeparatorView>(
        elementKind: SeparatorView.cellSeparatorElementKind,
        handler: { _, _, _ in }
    )
    var sectionSeparatorRegistration = UICollectionView.SupplementaryRegistration<SeparatorView>(
        elementKind: SeparatorView.sectionSeparatorElementKind,
        handler: { _, _, _ in }
    )

    // MARK: Private

    private let configuration: Configuration

    private var isHighlightable = false
}
