//
//  ActivityIndicatorSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/17.
//

import UIKit

/// A section that displays an activity indicator within a collection view.
///
/// `ActivityIndicatorSection` is designed for displaying a loading or progress indicator in a collection view layout.
/// It can be useful for showing ongoing background tasks, data loading processes, or other waiting states
/// within a collection view context.
///
/// ### Usage
/// ```swift
/// let activityIndicatorSection = ActivityIndicatorSection()
/// ```
///
/// - Important: Ensure to configure the appearance and behavior of the activity indicator according to the app's loading requirements.
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

    @discardableResult
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
        return section
    }

    open func isHighlightable(for index: Int) -> Bool {
        return false
    }

    open func updateItems(with difference: CollectionDifference<AnyHashable>) {}

    // MARK: Public

    /// A structure representing the content and appearance of an indicator.
    ///
    /// `IndicatorContent` is used to define properties for an indicator, including an optional title
    /// and customizable appearance settings. This can be useful for components that need to display
    /// indicators with varying styles and labels.
    ///
    /// ### Usage
    /// ```swift
    /// let indicator = IndicatorContent(title: "Loading", appearance: .default)
    /// ```
    ///
    /// - Note: This structure conforms to `Hashable`, allowing it to be used in hashed collections.
    public struct IndicatorContent: Hashable {
        // MARK: Lifecycle

        /// Initializes a new `IndicatorContent` with an optional title and appearance settings.
        ///
        /// - Parameters:
        ///   - title: An optional title for the indicator. Defaults to `nil`.
        ///   - appearance: The appearance configuration for the indicator. Defaults to `.init()`.
        public init(title: String? = nil, appearance: IndicatorAppearance = .init()) {
            self.title = title
            self.appearance = appearance
        }

        // MARK: Public

        // MARK: Properties

        /// The optional title of the indicator, displayed alongside or within the indicator.
        public let title: String?

        /// The appearance settings for the indicator, defining its style and visual characteristics.
        public let appearance: IndicatorAppearance
    }

    /// A structure representing the appearance of an activity indicator, including style and tint color.
    ///
    /// `IndicatorAppearance` is used to define the visual style of an indicator, allowing customization of
    /// its size, color, and other stylistic details. This structure can be applied to components that require
    /// activity indicators with specific styles.
    ///
    /// ### Usage
    /// ```swift
    /// let appearance = IndicatorAppearance(style: .large, tintColor: .blue)
    /// ```
    ///
    /// - Note: This structure conforms to `Hashable`, making it suitable for use in hashed collections.
    public struct IndicatorAppearance: Hashable {
        // MARK: Lifecycle

        /// Initializes a new `IndicatorAppearance` with a specified style and optional tint color.
        ///
        /// - Parameters:
        ///   - style: The style of the activity indicator, defining its size and appearance. Defaults to `.medium`.
        ///   - tintColor: An optional color for the activity indicator. If `nil`, the default color is used.
        public init(style: UIActivityIndicatorView.Style = .medium, tintColor: UIColor? = nil) {
            self.style = style
            self.tintColor = tintColor
        }

        // MARK: Public

        // MARK: Properties

        /// The style of the activity indicator, determining its size and appearance.
        public let style: UIActivityIndicatorView.Style

        /// The tint color of the activity indicator. If `nil`, the indicator uses its default color.
        public let tintColor: UIColor?
    }

    public typealias Cell = ActivityIndicatorCell
    public typealias Item = IndicatorContent

    public var id: String

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
}
