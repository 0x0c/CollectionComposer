//
//  ButtonSectionContext.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/04.
//

import UIKit

@available(iOS 16.0, *)
public struct ButtonSectionContext: Hashable {
    // MARK: Lifecycle

    init(id: String, configuration: ButtonConfiguration, handler: @escaping Handler) {
        self.id = id
        self.configuration = configuration
        action = UIAction(handler: { _ in
            handler(id)
        })
    }

    // MARK: Public

    public typealias Handler = (_ id: String) -> Void

    public static func == (lhs: ButtonSectionContext, rhs: ButtonSectionContext) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: Internal

    let id: String
    let configuration: ButtonConfiguration
    let action: UIAction
}
