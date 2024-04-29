//
//  SwiftUICellSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

@available(iOS 16.0, *)
open class SwiftUICellSection<View: SwiftUICellView & SwiftUI.View>: CollectionComposer.Section {
    // MARK: Lifecycle

    public init(id: String, items: [View.Model]) {
        self.id = id
        self.items = items
    }

    // MARK: Open

    open var id: String

    open var cellRegistration: UICollectionView.CellRegistration<
        UICollectionViewCell,
        View.Model
    >! = UICollectionView.CellRegistration<UICollectionViewCell, View.Model> { cell, _, model in
        cell.contentConfiguration = UIHostingConfiguration { View(model) }
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
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        return NSCollectionLayoutSection(group: group)
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Public

    public typealias Cell = UICollectionViewCell
    public typealias Item = View.Model
}
