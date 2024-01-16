//
//  SectionDataSource.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/08.
//

import Foundation

// MARK: - SectionDataSource

/// `SectionDataSource` is a protocol for specifically holding and managing sections.
public protocol SectionDataSource: AnyObject {
    /// An array for storing sections.
    var sections: [any Section] { get }

    /// A function for storing sections.
    func store(_ sections: [any Section])
    /// A function to retrieve the section for a given index.
    /// - Parameters:
    ///   - sectionIndex: Index for section
    func section(for sectionIndex: Int) -> any Section
}

public extension SectionDataSource {
    func section(for sectionIndex: Int) -> any Section {
        return sections[sectionIndex]
    }
}
