//
//  SupplementaryView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/12.
//

import UIKit

// MARK: - SupplementaryView

/// A protocol defining a supplementary view that can be used in a collection view layout.
///
/// Conforming types define the characteristics of a supplementary view, such as its
/// element kind, layout size, alignment, and various positioning properties.
///
/// This protocol also provides methods to prepare the view and to dequeue it from a collection view.
///
/// - Note: This protocol is annotated with `@MainActor`, so all methods and properties
///         are expected to be used on the main thread.
@MainActor
public protocol SupplementaryView {
    /// The type of content view that conforms to `UICollectionReusableView`.
    ///
    /// This associated type specifies the specific type of the view
    /// that will be used as a supplementary view.
    associatedtype ContentView: UICollectionReusableView

    /// A string that identifies the kind of element for this supplementary view.
    ///
    /// This string should match the element kind identifier registered
    /// with the collection view layout.
    var elementKind: String { get }

    /// The layout size of the supplementary view.
    ///
    /// Defines the width and height of the view within the collection view layout.
    var layoutSize: NSCollectionLayoutSize { get }

    /// The alignment of the supplementary view within the collection view layout.
    ///
    /// Defines how the supplementary view is positioned in relation to the collection view's bounds.
    var alignment: NSRectAlignment { get }

    /// The offset of the supplementary view relative to its default position.
    ///
    /// Specifies a point that is used to shift the view along the x and y axes.
    var absoluteOffset: CGPoint { get }

    /// A Boolean value that indicates whether the supplementary view should remain visible
    /// when scrolling.
    ///
    /// If `true`, the view stays pinned to visible bounds.
    var pinToVisibleBounds: Bool { get }

    /// A Boolean value that determines whether the supplementary view can extend
    /// beyond the collection view's boundaries.
    ///
    /// If `true`, the view can extend past the default boundary limits.
    var extendsBoundary: Bool { get }

    /// Prepares the supplementary view for display.
    ///
    /// Use this method to perform any setup necessary before the view
    /// is displayed in the collection view.
    func prepare()

    /// Dequeues a reusable supplementary view from the given collection view.
    ///
    /// This method retrieves a supplementary view of the specified type
    /// from the collection view's reuse queue and returns it, ready for configuration.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view that provides the reusable view.
    ///   - indexPath: The index path specifying the location of the view.
    /// - Returns: A `UICollectionReusableView` instance dequeued from the reuse queue.
    func dequeueReusableSupplementary(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView
}

// MARK: - BoundarySupplementaryView

/// A protocol that extends `SupplementaryView` to define a supplementary view
/// positioned at the boundary of a collection view layout.
///
/// Conforming types add properties and methods specific to boundary supplementary views,
/// including a registration property and a method for creating a boundary supplementary item.
///
/// - Note: This protocol is annotated with `@MainActor`, so all methods and properties
///         are expected to be used on the main thread.
@MainActor
public protocol BoundarySupplementaryView: SupplementaryView {
    /// A supplementary registration object used to configure and register the content view
    /// for this boundary supplementary view.
    ///
    /// This registration object defines how the supplementary view should be initialized
    /// and configured when it is dequeued.
    var registration: UICollectionView.SupplementaryRegistration<ContentView>! { get }

    /// Creates and returns a boundary supplementary item to be used in the collection view layout.
    ///
    /// This item specifies the positioning and layout attributes for the boundary supplementary view,
    /// allowing it to be placed at the edges of the layout section.
    ///
    /// - Returns: An `NSCollectionLayoutBoundarySupplementaryItem` that defines
    ///            the layout characteristics of the boundary view.
    func boundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem
}

// MARK: - BoundarySupplementaryHeaderView

/// A protocol that extends `BoundarySupplementaryView` to define a supplementary header view
/// positioned at the boundary of a collection view layout.
///
/// Conforming types specify properties specific to header views, such as the header mode configuration,
/// allowing the header view to be customized according to the layout's requirements.
///
/// - Note: This protocol is annotated with `@MainActor`, so all methods and properties
///         are expected to be used on the main thread.
@MainActor
public protocol BoundarySupplementaryHeaderView: BoundarySupplementaryView {
    /// The mode configuration for the header in a list-based collection view layout.
    ///
    /// This property specifies the behavior and appearance of the header
    /// within a list configuration, such as being hidden or pinned.
    var headerMode: UICollectionLayoutListConfiguration.HeaderMode { get }
}

public extension BoundarySupplementaryHeaderView {
    var alignment: NSRectAlignment { .top }
}

// MARK: - BoundarySupplementaryFooterView

/// A protocol that extends `BoundarySupplementaryView` to define a supplementary footer view
/// positioned at the boundary of a collection view layout.
///
/// Conforming types specify properties specific to footer views, such as the footer mode configuration,
/// allowing the footer view to be customized according to the layout's requirements.
///
/// - Note: This protocol is annotated with `@MainActor`, so all methods and properties
///         are expected to be used on the main thread.
@MainActor
public protocol BoundarySupplementaryFooterView: BoundarySupplementaryView {
    /// The mode configuration for the footer in a list-based collection view layout.
    ///
    /// This property specifies the behavior and appearance of the footer
    /// within a list configuration, such as being hidden or pinned.
    var footerMode: UICollectionLayoutListConfiguration.FooterMode { get }
}

public extension BoundarySupplementaryFooterView {
    var alignment: NSRectAlignment { .bottom }
}

public extension BoundarySupplementaryView {
    func dequeueReusableSupplementary(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
    }

    func boundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSize,
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset
        )
        item.pinToVisibleBounds = pinToVisibleBounds
        item.extendsBoundary = extendsBoundary
        return item
    }
}
