//
//  SwiftUIViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/04/29.
//

import CollectionComposer
import SwiftUI

class SwiftUIViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    lazy var sectionDataSource: CollectionComposer.SectionDataSource = self

    private(set) var sections = [any CollectionComposer.Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"

        provider = self
        store(animate: false) {
            SwiftUISection(
                id: "swift-ui-section",
                configuration: UIHostingConfiguration {
                    ChartView(data: [
                        .init(type: "Cube", count: 5),
                        .init(type: "Sphere", count: 4),
                        .init(type: "Pyramid", count: 4)
                    ])
                }
            )
            SwiftUICellSection<ExampleCellView>(
                id: "swift-ui-cell-section",
                items: [
                    .init(title: "Example1"),
                    .init(title: "Example2"),
                    .init(title: "Example3")
                ],
                configuration: .cellSeparator(highlightable: true)
            )
        }
    }

    override func didSelectItem(_ item: AnyHashable, in section: any CollectionComposer.Section, at indexPath: IndexPath) {
        if section is ListSection, let item = item as? ListItem {
            print(item)
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
