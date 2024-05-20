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
            SwiftUISection(id: "swift-ui-section") {
                ChartView(data: [
                    .init(type: "Cube", count: 5),
                    .init(type: "Sphere", count: 4),
                    .init(type: "Pyramid", count: 4)
                ])
            }
            SwiftUISection(id: "swift-ui-section2") {
                ChartView(data: [
                    .init(type: "Cube", count: 5),
                    .init(type: "Sphere", count: 4),
                    .init(type: "Pyramid", count: 4)
                ])
            }.header(SwiftUISupllementaryHeaderView(
                elementKind: "swift-ui-header1",
                configuration: UIHostingConfiguration(content: {
                    Label(title: { Text("Label") }, icon: { Image(systemName: "42.circle") })
                })
            ))
            SwiftUIListCellSection<ExampleCellView>(
                id: "swift-ui-cell-section",
                items: [
                    .init(title: "Example1-1"),
                    .init(title: "Example1-2"),
                    .init(title: "Example1-3")
                ],
                configuration: .defaultConfiguration(highlightable: true)
            ).indexTitle("B")
                .header(PlainHeaderView("B"))
            SwiftUIListCellSection<ExampleCellView>(
                id: "swift-ui-cell-section2",
                items: [
                    .init(title: "Example2-1"),
                    .init(title: "Example2-2"),
                    .init(title: "Example2-3")
                ],
                configuration: .defaultConfiguration(highlightable: true)
            ).indexTitle("C")
                .header(PlainHeaderView("C"))
            SwiftUIListCellSection<ExampleCellView>(
                id: "swift-ui-cell-section3",
                items: [
                    .init(title: "Example3-1"),
                    .init(title: "Example3-2"),
                    .init(title: "Example3-3")
                ],
                configuration: .defaultConfiguration(highlightable: true)
            ).indexTitle("D")
                .header(
                    SwiftUISupllementaryHeaderView(
                        elementKind: "swift-ui-header2",
                        pinToVisibleBounds: true,
                        configuration: UIHostingConfiguration(content: {
                            Label(title: { Text("Label") }, icon: { Image(systemName: "42.circle") })
                        })
                    )
                )
            SwiftUIListCellSection<ExampleCellView>(
                id: "swift-ui-cell-section4",
                items: [
                    .init(title: "Example4-1"),
                    .init(title: "Example4-2"),
                    .init(title: "Example4-3")
                ],
                configuration: .defaultConfiguration(highlightable: true)
            ).indexTitle("E")
                .footer(
                    SwiftUISupllementaryFooterView(
                        elementKind: "swift-ui-footer",
                        configuration: UIHostingConfiguration(content: {
                            Label(title: { Text("Label") }, icon: { Image(systemName: "42.circle") })
                        })
                    )
                )
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
