//
//  TextForm.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/03.
//

import Combine
import UIKit

// MARK: - TextForm

open class TextForm: NSObject {
    // MARK: Lifecycle

    public init(
        label: String? = nil,
        placeholder: String? = nil,
        inputStyle: InputStyle = .text(nil, TextInputContext())
    ) {
        self.label = label
        self.placeholder = placeholder
        self.inputStyle = inputStyle

        switch inputStyle {
        case let .text(initialText, _):
            currentInput = .text(initialText)
        case let .datePicker(context):
            currentInput = .date(context.initialDate, context.formatter)
        case let .picker(context):
            currentInput = .text(context.initialTitle)
        }
    }

    public convenience init(
        label: String? = nil,
        text: String? = nil,
        placeholder: String? = nil,
        isSecureText: Bool = false
    ) {
        self.init(
            label: label,
            placeholder: placeholder,
            inputStyle: .text(text, TextInputContext(isSecureText: isSecureText))
        )
    }

    // MARK: Open

    @discardableResult
    open func validate(_ handler: @escaping (Input?) -> ValidationResult) -> Self {
        validationHandler = handler
        return self
    }

    @discardableResult
    open func focuseNext() -> Bool {
        guard let next else {
            return false
        }
        next._shouldFocusTextFieldSubject.send(())
        return true
    }

    @discardableResult
    open func focusePrevious() -> Bool {
        guard let previous else {
            return false
        }
        previous._shouldFocusTextFieldSubject.send(())
        return true
    }

    // MARK: Public

    public enum InputStyle {
        case text(String?, TextInputContext)
        case datePicker(DatePickerContext = DatePickerContext())
        case picker(PickerContext)
    }

    public struct PickerContext {
        // MARK: Lifecycle

        public init(titles: [String], initialSelection: Int = 0) {
            self.titles = titles
            self.initialSelection = max(0, min(titles.count - 1, initialSelection))
        }

        // MARK: Public

        public let titles: [String]
        public let initialSelection: Int

        public var initialTitle: String? {
            if titles.count > initialSelection {
                return titles[initialSelection]
            }
            return nil
        }
    }

    public struct DatePickerContext {
        // MARK: Lifecycle

        public init(_ initialDate: Date? = nil, mode: UIDatePicker.Mode = .date, formatter: DateFormatter? = nil) {
            self.initialDate = initialDate
            self.mode = mode
            self.formatter = formatter
        }

        // MARK: Public

        public let initialDate: Date?
        public let mode: UIDatePicker.Mode
        public let formatter: DateFormatter?
    }

    public struct TextInputContext {
        // MARK: Lifecycle

        public init(
            isSecureText: Bool = false,
            keyboardType: UIKeyboardType = .default,
            spellCheckingType: UITextSpellCheckingType = .default,
            autocorrectionType: UITextAutocorrectionType = .default,
            autocapitalizationType: UITextAutocapitalizationType = .none,
            contentType: UITextContentType? = nil
        ) {
            self.isSecureText = isSecureText
            self.keyboardType = keyboardType
            self.spellCheckingType = spellCheckingType
            self.autocorrectionType = autocorrectionType
            self.autocapitalizationType = autocapitalizationType
            self.contentType = contentType
        }

        // MARK: Public

        public let isSecureText: Bool
        public let keyboardType: UIKeyboardType
        public let spellCheckingType: UITextSpellCheckingType
        public let autocorrectionType: UITextAutocorrectionType
        public let autocapitalizationType: UITextAutocapitalizationType
        public let contentType: UITextContentType?
    }

    public enum ValidationResult {
        case valid
        case invalid(hint: String)
    }

    public enum Input: Sendable {
        case text(String?)
        case date(Date?, DateFormatter?)

        // MARK: Public

        public var count: Int {
            switch self {
            case let .text(string):
                return string?.count ?? 0
            case let .date(date, _):
                return date == nil ? 0 : 1
            }
        }

        public func toString() -> String? {
            switch self {
            case let .text(string):
                return string
            case let .date(date, formatter):
                if let date {
                    return formatter?.string(from: date) ?? date.description
                }
                return nil
            }
        }
    }

    public let inputStyle: InputStyle

    public lazy var shouldFocusTextFieldPublisher = _shouldFocusTextFieldSubject.eraseToAnyPublisher()
    public var label: String?
    @Published public var currentInput: Input?
    public var placeholder: String?
    public var validationHandler: ((Input?) -> ValidationResult)?

    public func bind(_ cell: TextFormCell) -> [AnyCancellable] {
        cell.textField.placeholder = placeholder
        switch inputStyle {
        case let .text(_, context):
            cell.textField.isSecureTextEntry = context.isSecureText
            cell.textField.keyboardType = context.keyboardType
            cell.textField.spellCheckingType = context.spellCheckingType
            cell.textField.autocorrectionType = context.autocorrectionType
            cell.textField.autocapitalizationType = context.autocapitalizationType
        case .datePicker, .picker:
            cell.textField.isHidden = true
        }
        return [
            $currentInput.map { input in
                input?.toString()
            }.assign(to: \UILabel.text, on: cell.pickerValueLabel),
            $currentInput.map { input in
                input?.toString()
            }.assign(to: \UITextField.text, on: cell.textField)
        ]
    }

    public func currentDatePicker() -> UIDatePicker? {
        if case let .datePicker(context) = inputStyle {
            if let datePicker {
                return datePicker
            }
            else {
                let picker = UIDatePicker()
                if let initialDate = context.initialDate {
                    picker.date = initialDate
                }
                picker.addTarget(self, action: #selector(didDatePickerValueChange), for: .valueChanged)
                picker.preferredDatePickerStyle = .wheels
                picker.datePickerMode = context.mode
                return picker
            }
        }
        return nil
    }

    public func currentPickerView() -> UIPickerView? {
        if case let .picker(context) = inputStyle {
            if let pickerView {
                return pickerView
            }
            else {
                let picker = UIPickerView()
                picker.delegate = self
                picker.dataSource = self
                picker.selectRow(context.initialSelection, inComponent: 0, animated: false)
                pickerView = picker
                return picker
            }
        }
        return nil
    }

    // MARK: Internal

    var next: TextForm?
    var previous: TextForm?

    // MARK: Private

    private var datePicker: UIDatePicker?

    private var pickerView: UIPickerView?

    private var _shouldFocusTextFieldSubject = PassthroughSubject<Void, Never>()
    private let id = UUID()

    @objc
    private func didDatePickerValueChange(_ sender: UIDatePicker) {
        if case let .datePicker(context) = inputStyle {
            currentInput = .date(sender.date, context.formatter)
        }
    }
}

// MARK: UIPickerViewDelegate, UIPickerViewDataSource

extension TextForm: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - UIPickerViewDataSource

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if case let .picker(context) = inputStyle {
            return context.titles.count
        }
        return 0
    }

    // MARK: - UIPickerViewDelegate

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if case let .picker(context) = inputStyle {
            return context.titles[row]
        }
        return nil
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if case let .picker(context) = inputStyle {
            currentInput = .text(context.titles[row])
        }
    }
}
