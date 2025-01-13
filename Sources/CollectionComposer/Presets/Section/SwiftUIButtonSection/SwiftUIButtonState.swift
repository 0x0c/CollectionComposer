//
//  SwiftUIButtonState.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2025/01/13.
//

import SwiftUI

@available(iOS 16.0, *)
public class SwiftUIButtonState: ObservableObject {
    // MARK: Lifecycle

    public init(isEnabled: Bool = false) {
        self.isEnabled = isEnabled
    }

    // MARK: Public

    @Published public var isEnabled = false
}
