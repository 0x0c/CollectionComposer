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

    lazy var externalInputForm = TextForm(
        label: "External Input",
        placeholder: "Placeholder",
        inputStyle: .externalInput(nil) { [weak self] _ in
            guard let self else {
                return
            }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "External input"
            alert.addTextField()
            alert.addAction(
                UIAlertAction(title: "Add", style: .default) { _ in
                    self.updateExternalInputForm(alert.textFields?.first?.text)
                }
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true, completion: nil)
        }
    )

    var sectionDataSource: CollectionComposer.SectionDataSource { self }

    func updateExternalInputForm(_ text: String?) {
        if let text {
            externalInputForm.currentInput = TextForm.Input.text(text)
        }
    }

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
                    .validation { form in
                        guard let input = form.currentInput else {
                            return .invalid(hint: .string("Password should not be empty."))
                        }
                        if input.count >= 10 {
                            return .valid
                        }
                        return .invalid(hint: .string("Password should be longer than 10 characters."))
                    }
            }
            TextFormSection<InputFieldCell>(id: "text2", type: .nib(UINib(nibName: "InputFieldCell", bundle: nil))) {
                TextForm(label: "Label", text: "Initial text", placeholder: "Placeholder")
                TextForm(placeholder: "Email")
                TextForm(placeholder: "Password", isSecureText: true)
                    .validation { form in
                        guard let input = form.currentInput else {
                            return .invalid(hint: .string("Password should not be empty."))
                        }
                        if input.count >= 10 {
                            return .valid
                        }
                        return .invalid(hint: .string("Password should be longer than 10 characters."))
                    }
            }
            TextFormSection<RoundedTextFormCell>(id: "external") {
                externalInputForm
            }
            TextFormSection<RoundedTextFormCell>(id: "picker") {
                TextForm(
                    placeholder: "Picker",
                    inputStyle: .picker(TextForm.PickerContext(items: ["A", "B", "C"]))
                ).onFocused {
                    print("focused \($0.label ?? "")")
                }.onResigned {
                    print("resigned \($0.label ?? "")")
                }
                TextForm(
                    placeholder: "Picker",
                    inputStyle: .picker(
                        TextForm.PickerContext(
                            items: ["A", "B", "C"],
                            initialSelection: 2
                        )
                    )
                )
                TextForm(placeholder: "Date picker", inputStyle: .datePicker(.init(nil, formatter: dateFormatter)))
                TextForm(placeholder: "Time picker", inputStyle: .datePicker(.init(.now, mode: .time, formatter: dateFormatter)))
                TextForm(placeholder: "Date picker (initial picker date)", inputStyle: .datePicker(.init(initialPickerDate: Date(timeIntervalSince1970: 0), formatter: dateFormatter)))
                TextForm(placeholder: "Date and time picker", inputStyle: .datePicker(.init(.now, mode: .dateAndTime, formatter: dateFormatter)))
                TextForm(placeholder: "Date and time picker", inputStyle: .datePicker(.init(.now)))
                    .allowsToShowKeyboard(false)
                    .onFocused { _ in
                        print("focused but dont show keyboard")
                    }
                TextForm(placeholder: "YYYYMMDD (Auto resign)", inputStyle: .datePicker()).onFocused { form in
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
