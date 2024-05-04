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
            SwiftUIListCellSection<ExampleCellView>(
                id: "swift-ui-cell-section",
                items: [
                    .init(title: "Example1"),
                    .init(title: "Example2"),
                    .init(title: "Example3")
                ],
                configuration: .defaultConfiguration(highlightable: true)
            ).indexTitle("B")
                .header(.plain("B"))
            SwiftUIListCellSection<ExampleCellView>(
                id: "swift-ui-cell-section2",
                items: [
                    .init(title: "Example2-1"),
                    .init(title: "Example2-2"),
                    .init(title: "Example2-3")
                ],
                configuration: .defaultConfiguration(highlightable: true)
            ).indexTitle("C")
                .header(.plain("C"))
        }
    }

    override func didSelectItem(_ item: AnyHashable, in section: any CollectionComposer.Section, at indexPath: IndexPath) {
        if section is SwiftUIListCellSection<ExampleCellView>, let item = item as? ExampleData {
            print(item)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
