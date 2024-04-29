//
//  DividerSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/02/29.
//

import SwiftUI

@available(iOS 16.0, *)
open class DividerSection: SwiftUISection {
    public init() {
        super.init(id: UUID().uuidString, item: SwiftUISection.ViewConfiguration(UIHostingConfiguration { Divider() }))
    }
}
