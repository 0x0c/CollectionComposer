//
//  TextFormViewController.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/10/22.
//

import CollectionComposer
import UIKit

class TextFormViewController: ComposedCollectionViewController, SectionProvider, SectionDataSource {
    private(set) var sections = [any CollectionComposer.Section]()

    var sectionDataSource: CollectionComposer.SectionDataSource { self }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text form"

        view.keyboardLayoutGuide.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true

        provider = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        store {
//            TextFormSection<RoundedTextFormCell>(id: "text") {
//                TextForm(label: "Label", text: "Initial text", placeholder: "Placeholder")
//                TextForm(placeholder: "Email")
//                TextForm(placeholder: "Password", isSecureText: true)
//                    .validate { input in
//                        guard let input else {
//                            return .invalid(hint: "Password should not be empty.")
//                        }
//                        if input.count >= 10 {
//                            return .valid
//                        }
//                        return .invalid(hint: "Password should be longer than 10 characters.")
//                    }
//            }
            TextFormSection<RoundedTextFormCell>(id: "picker") {
//                TextForm(
//                    placeholder: "Picker",
//                    inputStyle: .picker(TextForm.PickerContext(titles: ["A", "B", "C"]))
//                )
//                TextForm(
//                    placeholder: "Picker",
//                    inputStyle: .picker(
//                        TextForm.PickerContext(
//                            titles: ["A", "B", "C"],
//                            initialSelection: 2
//                        )
//                    )
//                )
//                TextForm(placeholder: "Date picker", inputStyle: .datePicker(.init(.now, formatter: dateFormatter)))
//                TextForm(placeholder: "Time picker", inputStyle: .datePicker(.init(.now, mode: .time, formatter: dateFormatter)))
//                TextForm(placeholder: "Date and time picker", inputStyle: .datePicker(.init(.now, mode: .dateAndTime, formatter: dateFormatter)))
//                TextForm(placeholder: "Date and time picker", inputStyle: .datePicker(.init(.now)))
                TextForm(placeholder: "YYYYMMDD", inputStyle: .datePicker())
            }
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
