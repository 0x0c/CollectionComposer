//
//  ButtonSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/18.
//

import UIKit

@available(iOS 16.0, *)
open class ButtonSection: Section {
    // MARK: Lifecycle

    public init(id: String, configuration: Configuration, handler: @escaping ButtonSectionHandler) {
        self.id = id
        context = ButtonSectionContext(id: id, configuration: configuration, handler: handler)
        items = [context]
    }

    // MARK: Open

    open class ButtonCell: UICollectionViewCell {
        // MARK: Lifecycle

        override public init(frame: CGRect) {
            super.init(frame: frame)
            button.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(button)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: contentView.topAnchor),
                button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("not implemnted")
        }

        // MARK: Internal

        let button: UIButton = {
            let button = UIButton(frame: .zero)
            return button
        }()
    }

    open var cellRegistration: UICollectionView.CellRegistration<
        ButtonCell, ButtonSectionContext
    >! = UICollectionView.CellRegistration<ButtonCell, ButtonSectionContext> { cell, _, model in
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

    // MARK: Public

    public typealias ButtonSectionHandler = (_ id: String) -> Void
    public struct ButtonSectionContext: Hashable {
        // MARK: Lifecycle

        init(id: String, configuration: Configuration, handler: @escaping ButtonSectionHandler) {
            self.id = id
            self.configuration = configuration
            action = UIAction(handler: { _ in
                handler(id)
            })
        }

        // MARK: Public

        public static func == (lhs: ButtonSection.ButtonSectionContext, rhs: ButtonSection.ButtonSectionContext) -> Bool {
            lhs.id == rhs.id
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        // MARK: Internal

        let id: String
        let configuration: Configuration
        let action: UIAction
    }

    public typealias Cell = ButtonCell
    public typealias Item = ButtonSectionContext

    public struct Configuration: Hashable {
        // MARK: Lifecycle

        public init(configuration: UIButton.Configuration, title: String, buttonHeight: CGFloat = 44, contentInsets: NSDirectionalEdgeInsets = .zero) {
            buttonConfiguration = configuration
            buttonConfiguration.title = title
            self.buttonHeight = buttonHeight
            self.contentInsets = contentInsets
        }

        // MARK: Public

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        // MARK: Internal

        let id = UUID()
        var buttonConfiguration: UIButton.Configuration
        let buttonHeight: CGFloat
        let contentInsets: NSDirectionalEdgeInsets
    }

    // MARK: Internal

    let context: ButtonSectionContext
}
