//
//  TextViewSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2025/05/29.
//

import UIKit

open class TextViewSection: Section {
    // MARK: Lifecycle

    public init(id: String, string: StringRepresentation) {
        self.id = id
        item = string
    }

    // MARK: Open

    open var isExpanded: Bool = false

    open var item: StringRepresentation

    open var id: String
    open var contentInsetsReference: UIContentInsetsReference?
    open var supplementaryContentInsetsReference: UIContentInsetsReference?
    open var header: (any BoundarySupplementaryHeaderView)?
    open var footer: (any BoundarySupplementaryFooterView)?
    open var decorations: [Decoration] = []

    open var items: [StringRepresentation] {
        return [item]
    }

    open var snapshotItems: [AnyHashable] {
        [item]
    }

    open var isExpandable: Bool { false }

    open func contentInsetsReference(_ reference: UIContentInsetsReference) -> Self {
        contentInsetsReference = reference
        return self
    }

    open func supplementaryContentInsetsReference(_ reference: UIContentInsetsReference) -> Self {
        supplementaryContentInsetsReference = reference
        return self
    }

    open func layoutSection(for environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        return section
    }

    open func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?) {
        self.header = header
    }

    open func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?) {
        self.footer = footer
    }

    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    open func targetIndexPathForMoveOfItemFromOriginalIndexPath(
        _ proposedIndexPath: IndexPath,
        originalIndexPath: IndexPath,
        currentIndexPath: IndexPath
    ) -> IndexPath {
        if proposedIndexPath.section == originalIndexPath.section {
            return proposedIndexPath
        }
        return currentIndexPath
    }

    open func updateItems(with difference: CollectionDifference<AnyHashable>) {}

    // MARK: Public

    public typealias Cell = TextViewCell
    public typealias Item = StringRepresentation

    public let cellRegistration: UICollectionView.CellRegistration<
        TextViewCell,
        StringRepresentation
    >! = UICollectionView.CellRegistration<
        TextViewCell,
        StringRepresentation
    > { cell, _, string in
        cell.text = string
    }
}
