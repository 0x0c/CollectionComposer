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

    public init(id: String, configuration: Configuration = .defaultConfiguration(), item: ViewConfiguration) {
        self.id = id
        self.configuration = configuration
        items = [item]
    }

    public convenience init(id: String, configuration: Configuration = .defaultConfiguration(), contentConfiguration: UIContentConfiguration) {
        self.init(id: id, configuration: configuration, item: ViewConfiguration(contentConfiguration))
    }

    @available(iOS 16.0, *)
    public convenience init(id: String, configuration: Configuration = .defaultConfiguration(), @ViewBuilder content: () -> some View) {
        let viewConfiguration = if configuration.removeMargins {
            ViewConfiguration(UIHostingConfiguration { content() }.margins(.all, 0))
        }
        else {
            ViewConfiguration(UIHostingConfiguration { content() })
        }
        self.init(
            id: id,
            configuration: configuration,
            item: viewConfiguration
        )
    }

    // MARK: Open

    open var decorations = [Decoration]()
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

    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
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
        section.contentInsets = configuration.contentInsets
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Public

    public struct Configuration {
        public let contentInsets: NSDirectionalEdgeInsets
        public let removeMargins: Bool

        public static func defaultConfiguration(
            contentInsets: NSDirectionalEdgeInsets = .zero,
            removeMargins: Bool = true
        ) -> Configuration {
            return Configuration(
                contentInsets: contentInsets,
                removeMargins: removeMargins
            )
        }
    }

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

    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public func storeHeader(_ header: any BoundarySupplementaryHeaderView) {
        self.header = header
    }

    public func storeFooter(_ footer: any BoundarySupplementaryFooterView) {
        self.footer = footer
    }

    // MARK: Internal

    let configuration: Configuration
}
