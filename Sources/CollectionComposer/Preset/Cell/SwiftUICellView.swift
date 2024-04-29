//
//  SwiftUICellView.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/04/29.
//

import SwiftUI

public protocol SwiftUICellView {
    associatedtype Model: Hashable

    init(_ model: Model)
}
