//
//  TextFormSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/01.
//

import Combine
import UIKit

// MARK: - TextFormCell

public protocol TextFormCell: UICollectionViewCell {
    static var defaultTextFieldHeight: CGFloat { get }
    static var defaultHeight: CGFloat { get }

    func configure(_ form: TextForm)
}

// MARK: - TextFormSection

open class TextFormSection<T: TextFormCell>: Section {
    // MARK: Lifecycle

    public init(id: String, @ItemBuilder<TextForm> _ items: () -> [TextForm]) {
        self.id = id
        self.items = items()
        self.items.linkForms()
    }

    // MARK: Open

    open var cellRegistration: UICollectionView.CellRegistration<
        T, TextForm
    >! = UICollectionView.CellRegistration<T, TextForm> { cell, _, model in
        cell.configure(model)
    }

    open var isExpanded = false
    open var isExpandable = false

    open private(set) var items = [TextForm]()

    open var id: String

    open var snapshotItems: [AnyHashable] {
        return items
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(T.defaultHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(T.defaultHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Public
}

extension [TextForm] {
    func linkForms() {
        var iterator = makeIterator()
        var current: TextForm? = iterator.next()
        var previous: TextForm?
        while let next = iterator.next() {
            current?.previous = previous
            current?.next = next
            previous = current
            current = next
        }
    }
}
