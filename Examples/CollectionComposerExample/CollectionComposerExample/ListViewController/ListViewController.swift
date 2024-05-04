//
//  ListViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/04.
//

import CollectionComposer
import UIKit

class ListViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    lazy var sectionDataSource: CollectionComposer.SectionDataSource = self

    private(set) var sections = [any Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"

        provider = self
        store(animate: false) {
            ListSection(id: "first", apperarance: .plain) {
                ListItem(isHighlightable: true, text: "Item 1")
                ListItem(text: "Item 2")
                ListItem(text: "Item 3")
                ListItem(text: "Item 4")
                ListItem(text: "Item 5")
            }.header(.plain("Header"))
                .footer(.plain("Footer"))
                .indexTitle("A")
            ListSection(id: "second", apperarance: .insetGrouped) {
                ListItem(text: "Item 1", secondaryText: "Seconday")
                ListItem(text: "Item 2", secondaryText: "Seconday")
                ListItem(text: "Item 3", secondaryText: "Seconday")
                ListItem(text: "Item 4", secondaryText: "Seconday")
                ListItem(text: "Item 5", secondaryText: "Seconday")
            }.header(.plain("Expandable Header", isExpandable: true))
                .footer(.plain("Footer"))
                .indexTitle("B")
            ListSection(id: "third", apperarance: .insetGrouped) {
                ListItem(text: "Item 1", secondaryText: "Seconday")
                ListItem(text: "Item 2", secondaryText: "Seconday")
                ListItem(text: "Item 3", secondaryText: "Seconday")
                ListItem(text: "Item 4", secondaryText: "Seconday")
                ListItem(text: "Item 5", secondaryText: "Seconday")
            }.header(.plain("Expandable Header", isExpandable: true))
                .expand(false)
                .indexTitle("C")
            ListSection(id: "fourth", apperarance: .insetGrouped) {
                ListItem(text: "Item 1")
                ListItem(text: "Item 2")
                ListItem(text: "Item 3")
                ListItem(text: "Item 4")
                ListItem(text: "Item 5")
            }.indexTitle("D")
            ListSection(id: "fifth", cellStyle: .value) {
                ListItem(text: "Item 1", secondaryText: "Seconday")
                ListItem(text: "Item 2", secondaryText: "Seconday")
                ListItem(text: "Item 3", secondaryText: "Seconday")
                ListItem(text: "Item 4", secondaryText: "Seconday")
                ListItem(
                    text: "Item 5",
                    secondaryText: "Seconday",
                    accessories: [
                        .checkmark(),
                        .disclosureIndicator(options: .init(tintColor: .systemGray)),
                        .delete(),
                        .reorder()
                    ]
                )
            }.leadingSwipeActions(swipeActionProvider())
                .trailingSwipeActions(swipeActionProvider())
                .indexTitle("E")
        }
    }

    func swipeActionProvider() -> ListSection.SwipeActionConfigurationProvider {
        return { _ in
            let starAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                print("swipe action")
                completion(true)
            }
            starAction.image = UIImage(systemName: "star.slash")
            starAction.backgroundColor = .systemBlue
            return UISwipeActionsConfiguration(actions: [starAction])
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
