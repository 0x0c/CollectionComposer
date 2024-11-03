//
//  ButtonConfiguration.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/04.
//

import UIKit

/// A configuration structure for customizing a button within a collection view cell or other UI components.
///
/// `ButtonConfiguration` provides properties for setting the button's configuration, title, height, and content insets,
/// allowing for flexible button styling and layout. This struct conforms to `Hashable` for use in hashed collections
/// and unique identification within a list.
///
/// - Note: This struct is available on iOS 16.0 and later.
@available(iOS 16.0, *)
public struct ButtonConfiguration: Hashable {
    // MARK: Lifecycle

    /// Initializes a new button configuration with the specified settings.
    ///
    /// - Parameters:
    ///   - configuration: The `UIButton.Configuration` for customizing the button's appearance and behavior.
    ///   - title: The title text for the button.
    ///   - buttonHeight: The height of the button. Defaults to `44`.
    ///   - contentInsets: The insets applied around the button's content. Defaults to `.zero`.
    public init(configuration: UIButton.Configuration, title: String, buttonHeight: CGFloat = 44, contentInsets: NSDirectionalEdgeInsets = .zero) {
        buttonConfiguration = configuration
        buttonConfiguration.title = title
        self.buttonHeight = buttonHeight
        self.contentInsets = contentInsets
    }

    // MARK: Public

    /// Hashes the essential components of the configuration into the given hasher.
    ///
    /// - Parameter hasher: The hasher used to combine the values of the configuration.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: Internal

    /// A unique identifier for the configuration instance.
    let id = UUID()

    /// The configuration object that defines the appearance and behavior of the button.
    var buttonConfiguration: UIButton.Configuration

    /// The height of the button.
    ///
    /// This value defines the button’s height within its layout, defaulting to `44`.
    let buttonHeight: CGFloat

    /// Insets applied to the button content.
    ///
    /// Defines padding around the button content, defaulting to `.zero`.
    let contentInsets: NSDirectionalEdgeInsets
}
