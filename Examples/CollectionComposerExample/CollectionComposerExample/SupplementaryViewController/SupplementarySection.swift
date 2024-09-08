//
//  SupplementarySection.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/09.
//

import CollectionComposer
import UIKit

class SupplementarySection: Section {
    // MARK: Lifecycle

    init(id: String, @ItemBuilder<Item> items: () -> [Item]) {
        self.id = id
        self.items = items()
    }

    // MARK: Open

    open var decorations = [Decoration]()

    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    // MARK: Public

    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public func storeHeader(_ header: any BoundarySupplementaryHeaderView) {
        self.header = header
    }

    public func storeFooter(_ footer: any BoundarySupplementaryFooterView) {
        self.footer = footer
    }

    // MARK: Internal

    typealias Cell = TextCell
    typealias Item = Model

    struct Model: Hashable {
        let title: String

        let identifier = UUID()

        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    let id: String
    let items: [Model]

    let cellRegistration: UICollectionView.CellRegistration<TextCell, Model>! = UICollectionView.CellRegistration<TextCell, Model> { cell, _, model in
        cell.label.text = model.title
        cell.contentView.backgroundColor = .cyan
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1
        cell.label.textAlignment = .center
    }

    var isExpanded = false

    let headerRegistration = UICollectionView.SupplementaryRegistration
    <TextSupplementaryView>(elementKind: SupplementarySection.sectionHeaderElementKind) {
        supplementaryView, _, _ in
        supplementaryView.label.text = "header"
        supplementaryView.backgroundColor = .lightGray
        supplementaryView.layer.borderColor = UIColor.black.cgColor
        supplementaryView.layer.borderWidth = 1.0
    }

    let footerRegistration = UICollectionView.SupplementaryRegistration
    <TextSupplementaryView>(elementKind: SupplementarySection.sectionFooterElementKind) {
        supplementaryView, _, _ in
        supplementaryView.label.text = "footer"
        supplementaryView.backgroundColor = .lightGray
        supplementaryView.layer.borderColor = UIColor.black.cgColor
        supplementaryView.layer.borderWidth = 1.0
    }

    var identifier: String {
        return "supplementary-section-\(id)"
    }

    var snapshotItems: [AnyHashable] {
        return items.map { AnyHashable($0) }
    }

    var isExpandable: Bool {
        return false
    }

    func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [])
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.2)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementarySection.sectionHeaderElementKind,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementarySection.sectionFooterElementKind,
            alignment: .bottom
        )
        sectionFooter.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        return section
    }

    func supplementaryView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        if let supplementaryView = headerFooterSupplementaryView(collectionView, kind: kind, indexPath: indexPath) {
            return supplementaryView
        }
        switch kind {
        case SupplementarySection.sectionHeaderElementKind:
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        case SupplementarySection.sectionFooterElementKind:
            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
        default:
            return nil
        }
    }
}
