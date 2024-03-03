//
//  ButtonSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/18.
//

import UIKit

// MARK: - ButtonCell

@available(iOS 16.0, *)
public protocol ButtonCell: UICollectionViewCell {
    var button: UIButton { get }
}

// MARK: - ButtonSection

@available(iOS 16.0, *)
open class ButtonSection<T: ButtonCell>: Section {
    // MARK: Lifecycle

    public init(id: String, configuration: ButtonConfiguration, handler: @escaping ButtonSectionContext.Handler) {
        self.id = id
        context = ButtonSectionContext(id: id, configuration: configuration, handler: handler)
        items = [context]
    }

    // MARK: Open

    open var cellRegistration: UICollectionView.CellRegistration<
        T, ButtonSectionContext
    >! = UICollectionView.CellRegistration<T, ButtonSectionContext> { cell, _, model in
        cell.button.configuration = model.configuration.buttonConfiguration
        cell.button.addAction(model.action, for: .touchUpInside)
    }

    open var id: String
    open var items: [ButtonSectionContext]
    open var isExpanded = false
    open var isExpandable = false

    open var snapshotItems: [AnyHashable] {
        return items.map { AnyHashable($0.id) }
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(context.configuration.buttonHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = context.configuration.contentInsets
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Internal

    let context: ButtonSectionContext
}
