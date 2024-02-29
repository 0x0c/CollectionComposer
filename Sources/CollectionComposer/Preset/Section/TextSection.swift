//
//  TextSection.swift
//  TokyoBicycleParkingMap
//
//  Created by Akira Matsuda on 2024/01/21.
//

import CollectionComposer
import UIKit

open class TextSection: Section {
    // MARK: Lifecycle

    public init(_ stringRepresentation: StringRepresentation) {
        self.stringRepresentation = stringRepresentation
    }

    public convenience init(_ string: String) {
        self.init(StringRepresentation(text: string))
    }

    // MARK: Open

    open class TextCell: UICollectionViewCell {
        // MARK: Lifecycle

        override public init(frame: CGRect) {
            super.init(frame: frame)
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("not implemnted")
        }

        // MARK: Internal

        let label: UILabel = .init(frame: .zero)
    }

    open var cellRegistration: UICollectionView.CellRegistration<
        TextCell, StringRepresentation
    >! = UICollectionView.CellRegistration<TextCell, StringRepresentation> { cell, _, model in
        cell.label.text = model.text
        cell.label.textAlignment = model.textAlignment
        cell.label.font = model.font
    }

    open var stringRepresentation: StringRepresentation
    open var isExpanded = false
    open var isExpandable = false

    open var id: String {
        return uniqueId.uuidString
    }

    open var items: [StringRepresentation] {
        return [stringRepresentation]
    }

    open var snapshotItems: [AnyHashable] {
        return items
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(stringRepresentation.font.pointSize)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Public

    public struct StringRepresentation: Hashable {
        // MARK: Lifecycle

        public init(text: String, textAlignment: NSTextAlignment = .center, font: UIFont = .systemFont(ofSize: UIFont.labelFontSize)) {
            self.text = text
            self.textAlignment = textAlignment
            self.font = font
        }

        // MARK: Public

        public let text: String
        public let textAlignment: NSTextAlignment
        public let font: UIFont
    }

    public typealias Cell = TextCell
    public typealias Item = StringRepresentation

    // MARK: Private

    private var uniqueId = UUID()
}
