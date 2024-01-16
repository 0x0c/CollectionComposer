//
//  ComposedViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/01/16.
//

import CollectionComposer
import UIKit

class ComposedViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    lazy var sectionDataSource: CollectionComposer.SectionDataSource = self

    private(set) var sections = [any Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"

        provider = self
        store(animate: false) {
            ListSection(id: "first-list", apperarance: .plain) {
                ListItem(text: "Item 1")
                ListItem(text: "Item 2")
                ListItem(text: "Item 3")
            }.header(.plain("Header"))
                .footer(.plain("Footer"))
            SupplementarySection(id: "first-supplementary") {
                for index in 0 ... 25 {
                    SupplementarySection.Model(title: "\(index)")
                }
            }
            ListSection(id: "second-list", apperarance: .plain) {
                ListItem(text: "Item 1")
                ListItem(text: "Item 2")
                ListItem(text: "Item 3")
                ListItem(text: "Item 4")
                ListItem(text: "Item 5")
            }.header(.plain("Header"))
                .footer(.plain("Footer"))
        }
    }

    override func didSelectItem(_ item: AnyHashable, in section: any Section, at indexPath: IndexPath) {
        if section is ListSection, let item = item as? ListItem {
            print(item)
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
