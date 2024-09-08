//
//  ListViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/04.
//

import CollectionComposer
import SwiftUI
import UIKit

// MARK: - BackgroundDecorationView

open class BackgroundDecorationView: UICollectionReusableView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public static func decoration() -> Decoration {
        return Decoration(
            viewClass: BackgroundDecorationView.self,
            item: .background(elementKind: String(describing: BackgroundDecorationView.self))
        )
    }
}

// MARK: - ListViewController

class ListViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    private(set) var sections = [any CollectionComposer.Section]()

    var sectionDataSource: CollectionComposer.SectionDataSource { self }

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
            }.header(PlainHeaderView("Header"))
                .footer(PlainFooterView("Plain Footer"))
                .indexTitle("A")
            ListSection(id: "second", apperarance: .insetGrouped) {
                ListItem(text: "Item 1", secondaryText: "Seconday")
                ListItem(text: "Item 2", secondaryText: "Seconday")
                ListItem(text: "Item 3", secondaryText: "Seconday")
                ListItem(text: "Item 4", secondaryText: "Seconday")
                ListItem(text: "Item 5", secondaryText: "Seconday")
            }.header(PlainHeaderView("Expandable Header", isExpandable: true))
                .footer(PlainFooterView("Inset Group Footer"))
                .indexTitle("B")
            ListSection(id: "third", apperarance: .insetGrouped) {
                ListItem(text: "Item 1", secondaryText: "Seconday")
                ListItem(text: "Item 2", secondaryText: "Seconday")
                ListItem(text: "Item 3", secondaryText: "Seconday")
                ListItem(text: "Item 4", secondaryText: "Seconday")
                ListItem(text: "Item 5", secondaryText: "Seconday")
            }.header(PlainHeaderView("Expandable Header", isExpandable: true))
                .expand(false)
                .indexTitle("C")
            ListSection(id: "fourth", apperarance: .insetGrouped) {
                ListItem(text: "Item 1")
                ListItem(text: "Item 2")
                ListItem(text: "Item 3")
                ListItem(text: "Item 4")
                ListItem(text: "Item 5")
            }.indexTitle("D")
                .footer(PlainFooterView("Inset Group Footer"))
                .decorations([BackgroundDecorationView.decoration()])
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
                .header(
                    SwiftUISupllementaryHeaderView(elementKind: "swift-ui-header") {
                        Label(title: { Text("Label") }, icon: { Image(systemName: "42.circle") })
                    }
                )
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

    override func didSelectItem(_ item: AnyHashable, in section: any CollectionComposer.Section, at indexPath: IndexPath) {
        if section is ListSection, let item = item as? ListItem {
            print(item)
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
