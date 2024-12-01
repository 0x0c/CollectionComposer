//
//  LogInFormViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/03/01.
//

import CollectionComposer
import UIKit

class LogInFormViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    private(set) var sections = [any CollectionComposer.Section]()

    var sectionDataSource: CollectionComposer.SectionDataSource { self }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .save,
            primaryAction: UIAction(handler: { [weak self] _ in
                let result = self?.sections.compactMap {
                    $0 as? TextFormSection<RoundedTextFormCell>
                }.flatMap(\.items).compactMap { item in
                    item.currentInput?.toString()
                }.joined(separator: ", ")
                if let result {
                    print(result)
                }
            })
        )

        provider = self
        store {
            TextFormSection<RoundedTextFormCell>(id: "login") {
                TextForm(label: "Username", placeholder: "Your name")
                TextForm(placeholder: "Email")
                TextForm(placeholder: "Password", isSecureText: true)
                    .validation { input in
                        print("validate")
                        guard let input else {
                            return .invalid(hint: "Password should not be empty.")
                        }
                        if case let .text(text) = input,
                           let text,
                           text.count >= 10 {
                            return .valid
                        }
                        return .invalid(hint: "Password should be longer than 10 characters.")
                    }
                TextForm(placeholder: "Note")
            }
            TextFormSection<InputFieldCell>(id: "login2", type: .nib(UINib(nibName: "InputFieldCell", bundle: nil))) {
                TextForm(label: "Username", placeholder: "Your name")
                TextForm(label: "Email", placeholder: "Email")
                TextForm(label: "Password", placeholder: "Password", isSecureText: true)
                    .validation { input in
                        guard let input else {
                            return .invalid(hint: "Password should not be empty.")
                        }
                        if case let .text(text) = input,
                           let text,
                           text.count >= 10 {
                            return .valid
                        }
                        return .invalid(hint: "Password should be longer than 10 characters.")
                    }
                TextForm(label: "Note", placeholder: "Note")
            }
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
