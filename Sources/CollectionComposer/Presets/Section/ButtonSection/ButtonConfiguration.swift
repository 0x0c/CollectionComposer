//
//  ButtonConfiguration.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/04.
//

import UIKit

@available(iOS 16.0, *)
public struct ButtonConfiguration: Hashable {
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
