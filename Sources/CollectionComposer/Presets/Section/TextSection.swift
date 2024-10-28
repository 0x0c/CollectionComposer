//
//  TextSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/21.
//

import UIKit

// MARK: - TextCell

public protocol TextCell: UICollectionViewCell {
    func configure(_ configuration: StringConfiguration)
}

// MARK: - StringRepresentation

public enum StringRepresentation: Hashable {
    case plain(text: String, font: UIFont)
    case attributed(text: NSAttributedString)

    // MARK: Internal

    var fontSize: CGFloat {
        switch self {
        case let .plain(_, font):
            return font.pointSize
        case let .attributed(text):
            return text.size().height
        }
    }
}

// MARK: - StringConfiguration

public struct StringConfiguration: Hashable {
    // MARK: Lifecycle

    public init(_ representation: StringRepresentation, textAlignment: NSTextAlignment = .center) {
        self.representation = representation
        self.textAlignment = textAlignment
    }

    // MARK: Public

    public static func == (lhs: StringConfiguration, rhs: StringConfiguration) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    // MARK: Internal

    var representation: StringRepresentation
    var textAlignment: NSTextAlignment
}

// MARK: - BasicTextCell

open class BasicTextCell: UICollectionViewCell, TextCell {
    // MARK: Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        label.numberOfLines = 0
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

    // MARK: Public

    public func configure(_ configuration: StringConfiguration) {
        switch configuration.representation {
        case let .plain(text, font):
            label.text = text
            label.font = font
        case let .attributed(text):
            label.attributedText = text
        }
        label.textAlignment = configuration.textAlignment
    }

    // MARK: Private

    private let label: UILabel = .init(frame: .zero)
}

// MARK: - TextSection

open class TextSection<T: TextCell>: Section {
    // MARK: Lifecycle

    public init(_ configuration: StringConfiguration) {
        self.configuration = configuration
    }

    public convenience init(_ string: String) {
        self.init(
            StringConfiguration(
                .plain(
                    text: string,
                    font: UIFont.systemFont(ofSize: UIFont.labelFontSize)
                ),
                textAlignment: .center
            )
        )
    }

    // MARK: Open

    open var decorations = [Decoration]()
    open var cellRegistration: UICollectionView.CellRegistration<
        T, StringConfiguration
    >! = UICollectionView.CellRegistration<T, StringConfiguration> { cell, _, model in
        cell.configure(model)
    }

    open var configuration: StringConfiguration
    open var isExpanded = false
    open var isExpandable = false

    open var id: String {
        return uniqueId.uuidString
    }

    open var items: [StringConfiguration] {
        return [configuration]
    }

    open var snapshotItems: [AnyHashable] {
        return items
    }

    @discardableResult
    open func decorations(_ decorations: [Decoration]) -> Self {
        self.decorations = decorations
        return self
    }

    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(configuration.representation.fontSize)
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

    open func updateItems(with difference: CollectionDifference<AnyHashable>) {}

    // MARK: Public

    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public func targetIndexPathForMoveOfItemFromOriginalIndexPath(_ proposedIndexPath: IndexPath, originalIndexPath: IndexPath, currentIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.section == originalIndexPath.section {
            return proposedIndexPath
        }
        return currentIndexPath
    }

    public func storeHeader(_ header: (any BoundarySupplementaryHeaderView)?) {
        self.header = header
    }

    public func storeFooter(_ footer: (any BoundarySupplementaryFooterView)?) {
        self.footer = footer
    }

    // MARK: Private

    private var uniqueId = UUID()
}
