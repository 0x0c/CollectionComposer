//
//  SwiftUIListCellSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

@available(iOS 16.0, *)
open class SwiftUIListCellSection<View: SwiftUIListCellView>: CollectionComposer.IndexTitledSection {
    // MARK: Lifecycle

    public init(id: String, items: [View.Model], appearance: UICollectionLayoutListConfiguration.Appearance = .plain, configuration: Configuration = .defaultConfiguration()) {
        self.id = id
        self.items = items
        self.configuration = configuration
        listConfiguration = UICollectionLayoutListConfiguration(appearance: appearance)
        listConfiguration.separatorConfiguration = configuration.separatorConfiguration
    }

    // MARK: Open

    open var title: String?
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
        return NSCollectionLayoutSection.list(
            using: listConfiguration,
            layoutEnvironment: environment
        )
    }

    open func isHighlightable(for index: Int) -> Bool {
        return configuration.isHighlightable
    }

    open func indexTitle(_ title: String) -> any Section {
        self.title = title
        return self
    }

    // MARK: Public

    public struct Configuration {
        public let contentInsets: NSDirectionalEdgeInsets
        public let isHighlightable: Bool
        public let separatorConfiguration: UIListSeparatorConfiguration

        public static func defaultConfiguration(
            contentInsets: NSDirectionalEdgeInsets = .zero,
            highlightable: Bool = false,
            separatorConfiguration: UIListSeparatorConfiguration = UIListSeparatorConfiguration(listAppearance: .plain)
        ) -> Configuration {
            return Configuration(
                contentInsets: contentInsets,
                isHighlightable: highlightable,
                separatorConfiguration: separatorConfiguration
            )
        }
    }

    public typealias Cell = SwiftUIListCell<View>
    public typealias Item = View.Model

    public let id: String

    // MARK: Private

    private var listConfiguration: UICollectionLayoutListConfiguration
    private let configuration: Configuration
}
