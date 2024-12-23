//
//  TextSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/01/21.
//

import UIKit

// MARK: - TextCell

/// A protocol defining a collection view cell capable of displaying text.
///
/// `TextCell` provides a method to configure the cell with a specified `StringConfiguration`,
/// enabling the display of plain or attributed text content.
///
/// ### Usage
/// ```swift
/// class MyTextCell: UICollectionViewCell, TextCell {
///     func configure(_ configuration: StringConfiguration) {
///         // Configure the cell with the provided configuration
///     }
/// }
/// ```
///
/// - Important: Conforming cells should implement the `configure(_:)` method to display text.
public protocol TextCell: UICollectionViewCell {
    /// Configures the cell with the given text configuration.
    ///
    /// - Parameter configuration: The configuration containing the text representation and alignment for display.
    func configure(_ configuration: StringConfiguration)
}

// MARK: - StringRepresentation

/// An enumeration that represents different types of text content, either plain or attributed.
///
/// `StringRepresentation` allows the encapsulation of text content as either plain text with a specified font,
/// or as an attributed string. This provides flexibility in displaying text with various styles and formatting.
///
/// ### Usage
/// ```swift
/// let plainText = StringRepresentation.plain(text: "Hello", font: .systemFont(ofSize: 14))
/// let attributedText = StringRepresentation.attributed(text: NSAttributedString(string: "Hello"))
/// ```
///
/// - Note: This enum conforms to `Hashable`, making it suitable for use in hashed collections.
public enum StringRepresentation: Hashable {
    /// Plain text with a specified font.
    case plain(text: String, font: UIFont)

    /// Attributed text.
    case attributed(text: NSAttributedString)

    // MARK: Internal

    // MARK: Internal Properties

    /// The font size of the text, calculated based on the type of text representation.
    ///
    /// For plain text, it returns the point size of the associated font. For attributed text,
    /// it calculates the height of the text.
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

/// A configuration structure for displaying text within a cell, including alignment and representation.
///
/// `StringConfiguration` provides a way to configure how text should appear within a cell, defining both
/// the text representation (plain or attributed) and its alignment.
///
/// ### Usage
/// ```swift
/// let configuration = StringConfiguration(.plain(text: "Hello", font: .systemFont(ofSize: 14)), textAlignment: .center)
/// ```
///
/// - Note: This structure conforms to `Hashable`, allowing it to be used in hashed collections.
public struct StringConfiguration: Hashable {
    // MARK: Lifecycle

    /// Initializes a new `StringConfiguration` with the specified text representation and alignment.
    ///
    /// - Parameters:
    ///   - representation: The representation of the text, either plain or attributed.
    ///   - textAlignment: The alignment of the text within the cell. Defaults to `.center`.
    public init(_ representation: StringRepresentation, textAlignment: NSTextAlignment = .center) {
        self.representation = representation
        self.textAlignment = textAlignment
    }

    // MARK: Internal

    // MARK: Properties

    /// The representation of the text, defining its content and style.
    var representation: StringRepresentation

    /// The alignment of the text within the cell.
    var textAlignment: NSTextAlignment
}

// MARK: - BasicTextCell

/// A basic collection view cell for displaying text, supporting both plain and attributed text configurations.
///
/// `BasicTextCell` is a customizable text cell that conforms to `TextCell`, allowing it to be configured
/// with a `StringConfiguration`. The cell can display plain text with a specified font, or attributed text,
/// and supports customizable text alignment. This cell is designed for use in collection views where
/// simple text display is required.
///
/// - Note: This cell automatically resizes to fit the text content and supports multi-line text.
open class BasicTextCell: UICollectionViewCell, TextCell {
    // MARK: Lifecycle

    /// Initializes a new `BasicTextCell` instance with a specified frame.
    ///
    /// This initializer sets up the label within the cell, allowing for flexible multi-line text display and
    /// setting up auto layout constraints to ensure the label fills the cell’s content view.
    ///
    /// - Parameter frame: The frame rectangle for the cell, measured in points.
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

    /// Required initializer that triggers a runtime error if called, as this cell does not support storyboard use.
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    // MARK: Public

    // MARK: Public Methods

    /// Configures the cell with the provided text configuration.
    ///
    /// This method applies the configuration’s text representation (either plain or attributed) and
    /// alignment settings to the cell’s label.
    ///
    /// - Parameter configuration: The `StringConfiguration` containing the text representation and alignment.
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

    // MARK: Private Properties

    /// The label used to display text in the cell.
    private let label: UILabel = .init(frame: .zero)
}

// MARK: - TextSection

/// A section that displays a collection of text cells within a collection view.
///
/// `TextSection` is designed to manage a collection of text cells conforming to the `TextCell` protocol.
/// This section enables the display of textual data, supporting customization of each cell’s content and
/// configuration.
///
/// This class is generic over the type of `TextCell`, allowing any type conforming to `TextCell` to be used
/// as the cell type for this section.
///
/// ### Usage
/// ```swift
/// let textSection = TextSection<BasicTextCell>(id: "textSection", items: textConfigurations)
/// ```
///
/// - Note: `TextSection` works with any `TextCell` type, providing flexibility in displaying various types of text cells.
open class TextSection<T: TextCell>: Section {
    // MARK: Lifecycle

    /// Initializes an instance with a specified `StringConfiguration`.
    ///
    /// This initializer directly accepts a `StringConfiguration` object, allowing precise control over
    /// the text representation, font, and alignment.
    ///
    /// - Parameter configuration: The configuration defining the text representation and alignment.
    public init(_ configuration: StringConfiguration) {
        self.configuration = configuration
    }

    /// Convenience initializer that creates an instance with a plain text string.
    ///
    /// This initializer creates a default `StringConfiguration` using the provided string, with a plain
    /// text style, system font at the label font size, and centered alignment.
    ///
    /// ### Example
    /// ```swift
    /// let textInstance = MyTextClass("Hello, world!")
    /// ```
    ///
    /// - Parameter string: The plain text string to display.
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
        section.boundarySupplementaryItems = boundarySupplementaryItems
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
