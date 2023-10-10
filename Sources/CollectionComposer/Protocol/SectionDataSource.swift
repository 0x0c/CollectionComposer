//
//  SectionDataSource.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2023/10/08.
//

import Foundation

// MARK: - SectionDataSource

public protocol SectionDataSource: AnyObject {
    var sections: [any Section] { get set }

    func store(_ sections: [any Section])
    func section(for sectionIndex: Int) -> any Section
}

public extension SectionDataSource {
    func store(_ sections: [any Section]) {
        self.sections = sections
    }

    func section(for sectionIndex: Int) -> any Section {
        return sections[sectionIndex]
    }
}
