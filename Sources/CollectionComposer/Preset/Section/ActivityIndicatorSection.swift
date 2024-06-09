//
//  ActivityIndicatorSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/17.
//

import UIKit

open class ActivityIndicatorSection: Section {
    // MARK: Lifecycle

    public init(id: String = UUID().uuidString, indicator: IndicatorContent = .init()) {
        self.id = id
        items = [indicator]
    }

    public convenience init(id: String = UUID().uuidString, title: String? = nil, style: UIActivityIndicatorView.Style = .medium) {
        self.init(id: id, indicator: IndicatorContent(title: title, appearance: IndicatorAppearance(style: style)))
    }

    // MARK: Open

    open class ActivityIndicatorCell: UICollectionViewCell {
        // MARK: Lifecycle

        override public init(frame: CGRect) {
            super.init(frame: frame)
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            label.adjustsFontForContentSizeCategory = true
            label.font = UIFont.preferredFont(forTextStyle: .caption1)
            label.textColor = .secondaryLabel
            let stackView = UIStackView(arrangedSubviews: [
                indicatorView,
                label
            ])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.spacing = 8
            contentView.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
            indicatorView.startAnimating()
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("not implemnted")
        }

        // MARK: Internal

        let indicatorView = UIActivityIndicatorView()
        let label: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            return label
        }()
    }

    open var decorations = [Decoration]()
    open var cellRegistration: UICollectionView.CellRegistration<
        ActivityIndicatorCell,
        IndicatorContent
    >! = UICollectionView.CellRegistration<ActivityIndicatorCell, IndicatorContent> { cell, _, model in
        cell.indicatorView.style = model.appearance.style
        cell.label.text = model.title
    }

    open var items: [IndicatorContent]
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
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(20)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [])
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(20)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        if decorations.isEmpty == false {
            section.decorationItems = decorations.map(\.item)
        }
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    // MARK: Public

    public struct IndicatorContent: Hashable {
        // MARK: Lifecycle

        public init(title: String? = nil, appearance: IndicatorAppearance = .init()) {
            self.title = title
            self.appearance = appearance
        }

        // MARK: Internal

        let title: String?
        let appearance: IndicatorAppearance
    }

    public struct IndicatorAppearance: Hashable {
        // MARK: Lifecycle

        public init(style: UIActivityIndicatorView.Style = .medium, tintColor: UIColor? = nil) {
            self.style = style
            self.tintColor = tintColor
        }

        // MARK: Internal

        let style: UIActivityIndicatorView.Style
        let tintColor: UIColor?
    }

    public typealias Cell = ActivityIndicatorCell
    public typealias Item = IndicatorContent

    public var id: String

    public var header: (any BoundarySupplementaryHeaderView)?
    public var footer: (any BoundarySupplementaryFooterView)?

    public func storeHeader(_ header: any BoundarySupplementaryHeaderView) {
        self.header = header
    }

    public func storeFooter(_ footer: any BoundarySupplementaryFooterView) {
        self.footer = footer
    }
}
