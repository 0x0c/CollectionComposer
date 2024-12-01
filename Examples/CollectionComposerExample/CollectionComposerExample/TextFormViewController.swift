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

        provider = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        store {
            TextFormSection<RoundedTextFormCell>(id: "text") {
                TextForm(label: "Label", text: "Initial text", placeholder: "Placeholder")
                TextForm(placeholder: "Email")
                TextForm(placeholder: "Password", isSecureText: true)
                    .validation { input in
                        guard let input else {
                            return .invalid(hint: "Password should not be empty.")
                        }
                        if input.count >= 10 {
                            return .valid
                        }
                        return .invalid(hint: "Password should be longer than 10 characters.")
                    }
            }
            TextFormSection<InputFieldCell>(id: "text2", type: .nib(UINib(nibName: "InputFieldCell", bundle: nil))) {
                TextForm(label: "Label", text: "Initial text", placeholder: "Placeholder")
                TextForm(placeholder: "Email")
                TextForm(placeholder: "Password", isSecureText: true)
                    .validation { input in
                        guard let input else {
                            return .invalid(hint: "Password should not be empty.")
                        }
                        if input.count >= 10 {
                            return .valid
                        }
                        return .invalid(hint: "Password should be longer than 10 characters.")
                    }
            }
            TextFormSection<RoundedTextFormCell>(id: "picker") {
                TextForm(
                    placeholder: "Picker",
                    inputStyle: .picker(TextForm.PickerContext(titles: ["A", "B", "C"]))
                ).onFocused {
                    print("focused \($0.label ?? "")")
                }.onResigned {
                    print("resigned \($0.label ?? "")")
                }
                TextForm(
                    placeholder: "Picker",
                    inputStyle: .picker(
                        TextForm.PickerContext(
                            titles: ["A", "B", "C"],
                            initialSelection: 2
                        )
                    )
                )
                TextForm(placeholder: "Date picker", inputStyle: .datePicker(.init(.now, formatter: dateFormatter)))
                TextForm(placeholder: "Time picker", inputStyle: .datePicker(.init(.now, mode: .time, formatter: dateFormatter)))
                TextForm(placeholder: "Date and time picker", inputStyle: .datePicker(.init(.now, mode: .dateAndTime, formatter: dateFormatter)))
                TextForm(placeholder: "Date and time picker", inputStyle: .datePicker(.init(.now)))
                    .allowsToShowKeyboard(false)
                    .onFocused { _ in
                        print("focused but dont show keyboard")
                    }
                TextForm(placeholder: "YYYYMMDD", inputStyle: .datePicker()).onFocused { form in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        form.resignInputFieldFirstResponder()
                    }
                }
            }
        }
    }

    func store(_ sections: [any CollectionComposer.Section]) {
        self.sections = sections
    }
}
