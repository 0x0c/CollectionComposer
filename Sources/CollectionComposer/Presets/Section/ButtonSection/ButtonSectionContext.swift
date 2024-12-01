//
//  ButtonSectionContext.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/04.
//

import UIKit

/// A context structure for managing button configuration and actions within a `ButtonSection`.
///
/// `ButtonSectionContext` provides the necessary configuration and action handler for a button within a section.
/// It includes an identifier, button configuration, and a `UIAction` that triggers the handler when the button is tapped.
///
/// - Note: This struct is available on iOS 16.0 and later.
@available(iOS 16.0, *)
public struct ButtonSectionContext: Hashable {
    // MARK: Lifecycle

    /// Initializes a new button section context with the specified identifier, configuration, and action handler.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the button context.
    ///   - configuration: The configuration that defines the button’s appearance and layout.
    ///   - handler: A closure that handles the button action, receiving the context’s identifier as a parameter.
    init(id: String, configuration: ButtonConfiguration, handler: @escaping Handler) {
        self.id = id
        self.configuration = configuration
        action = UIAction(handler: { _ in
            handler(id)
        })
    }

    // MARK: Public

    /// A type alias for the button action handler.
    ///
    /// The handler receives the identifier of the button context when triggered.
    public typealias Handler = (_ id: String) -> Void

    /// Determines if two button section contexts are equal.
    ///
    /// Two contexts are considered equal if their identifiers match.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `ButtonSectionContext` to compare.
    ///   - rhs: The right-hand side `ButtonSectionContext` to compare.
    /// - Returns: `true` if the identifiers are the same; otherwise, `false`.
    public static func == (lhs: ButtonSectionContext, rhs: ButtonSectionContext) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the essential component of the configuration into the given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the values.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: Internal

    /// The unique identifier for the button context.
    let id: String

    /// The configuration object that defines the button’s appearance and behavior.
    let configuration: ButtonConfiguration

    /// The `UIAction` associated with the button, which triggers the handler when tapped.
    let action: UIAction
}
