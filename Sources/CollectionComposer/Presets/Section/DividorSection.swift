//
//  DividorSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/02/29.
//

import SwiftUI

/// A section that displays a divider line, intended for visually separating content within a collection view.
///
/// `DividerSection` is a specialized section that renders a horizontal line (`Divider`) for separating
/// different sections of content. This is a SwiftUI-based component, inheriting from `SwiftUISection`,
/// and is available on iOS 16.0 and later.
///
/// ### Usage
/// ```swift
/// let dividerSection = DividerSection()
/// ```
///
/// - Important: This class is available only on iOS 16.0 or later.
@available(iOS 16.0, *)
open class DividerSection: SwiftUISection {
    /// Creates a new `DividerSection` instance with a unique identifier and a SwiftUI divider view.
    ///
    /// This initializer sets up the section with a `Divider` view, using a unique ID generated from a UUID.
    public init() {
        super.init(id: UUID().uuidString, item: SwiftUISection.ViewConfiguration(UIHostingConfiguration { Divider() }))
    }
}
