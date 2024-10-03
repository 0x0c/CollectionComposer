//
//  IndexTitleSection.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/05/04.
//

import Foundation

/// IndexTitledSection allows to show index title at the right side of the collection view.
public protocol IndexTitleSection: Section, Sendable {
    /// A title for the section. Each title will be displayed as index titles.
    var title: String? { get set }

    /// Modifier to assign index title.
    func indexTitle(_ title: String) -> Self
}
