//
//  ViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2023/10/04.
//

import CollectionComposer
import UIKit

class ViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    struct Example: ListCellConfigurable {
        // MARK: Lifecycle

        init(_ kind: Kind) {
            self.kind = kind
        }

        // MARK: Internal

        enum Kind: String {
            case list
            case supplementary
            case composed
            case gallery
            case login
            case swiftui
            case textForm
        }

        let kind: Kind
        var image: UIImage?
        var attributedText: NSAttributedString?
        var secondaryText: String?
        var secondaryAttributedText: NSAttributedString?

        var isHighlightable: Bool {
            return true
        }

        var id: String {
            return kind.rawValue
        }

        var text: String? {
            return kind.rawValue.capitalized
        }

        var accessories: [UICellAccessory] {
            return [.disclosureIndicator()]
        }
    }

    private(set) var sections = [any Section]()

    var sectionDataSource: CollectionComposer.SectionDataSource { self }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Examples"

        provider = self
        store(animate: false) {
            ListSection(apperarance: .insetGrouped) {
                Example(.list)
                Example(.supplementary)
                Example(.composed)
                Example(.gallery)
                Example(.login)
                Example(.swiftui)
                Example(.textForm)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            selectedItems.forEach { collectionView.deselectItem(at: $0, animated: true) }
        }
    }

    override func didSelectItem(_ item: AnyHashable, in section: any Section, at indexPath: IndexPath) {
        guard let example = item as? Example else {
            return
        }
        switch example.kind {
        case .list:
            navigationController?.pushViewController(ListViewController(), animated: true)
        case .supplementary:
            navigationController?.pushViewController(SupplementaryViewController(), animated: true)
        case .composed:
            navigationController?.pushViewController(ComposedViewController(), animated: true)
        case .gallery:
            navigationController?.pushViewController(GalleryViewController(), animated: true)
        case .login:
            navigationController?.pushViewController(LogInFormViewController(), animated: true)
        case .swiftui:
            navigationController?.pushViewController(SwiftUIViewController(), animated: true)
        case .textForm:
            navigationController?.pushViewController(TextFormViewController(), animated: true)
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
