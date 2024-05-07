//
//  SwiftUISection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/18.
//

import SwiftUI

// MARK: - SwiftUISection

open class SwiftUISection: CollectionComposer.Section {
    // MARK: Lifecycle

    public init(id: String, contentInsets: NSDirectionalEdgeInsets = .zero, item: ViewConfiguration) {
        self.id = id
        self.contentInsets = contentInsets
        items = [item]
    }

    let contentInsets: NSDirectionalEdgeInsets
    
    public convenience init(id: String, contentInsets: NSDirectionalEdgeInsets = .zero, configuration: UIContentConfiguration) {
        self.init(id: id, contentInsets: contentInsets, item: ViewConfiguration(configuration))
    }

    @available(iOS 16.0, *)
    public convenience init(id: String, contentInsets: NSDirectionalEdgeInsets = .zero, @ViewBuilder content: () -> some View) {
        self.init(
            id: id,
            contentInsets: contentInsets,
            item: ViewConfiguration(
                UIHostingConfiguration {
                    content()
                }
            )
        )
    }

    // MARK: Open

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
        section.contentInsets = contentInsets
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Public

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
}
