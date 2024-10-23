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
        isRequired: Bool = false,
        inputStyle: InputStyle = .text(nil, TextInputContext())
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.inputStyle = inputStyle

        switch inputStyle {
        case let .text(initialText, _):
            currentInput = .text(initialText)
        case let .datePicker(context):
            currentInput = .date(context.initialDate, context.formatter)
        case let .picker(context):
            currentInput = context.initialSelection == nil ? nil : .text(context.initialTitle)
        }
    }

    public convenience init(
        label: String? = nil,
        text: String? = nil,
        placeholder: String? = nil,
        isRequired: Bool = false,
        isSecureText: Bool = false
    ) {
        self.init(
            label: label,
            placeholder: placeholder,
            isRequired: isRequired,
            inputStyle: .text(text, TextInputContext(isSecureText: isSecureText))
        )
    }

    // MARK: Open

    open class InputField: UITextField, UITextFieldDelegate {
        // MARK: Open

        override open func layoutSubviews() {
            super.layoutSubviews()
            delegate = self
            if coverView.superview == nil {
                setupCoverView()
            }
        }

        override open func caretRect(for position: UITextPosition) -> CGRect {
            if let form, form.inputStyle.isKindOfPicker {
                return .zero
            }
            return super.caretRect(for: position)
        }

        @discardableResult
        override open func becomeFirstResponder() -> Bool {
            coverView.isHidden = if let form, form.inputStyle.isKindOfPicker {
                false
            }
            else {
                true
            }
            return super.becomeFirstResponder()
        }

        @discardableResult
        override open func resignFirstResponder() -> Bool {
            coverView.isHidden = if let form, form.inputStyle.isKindOfPicker {
                true
            }
            else {
                false
            }
            return super.resignFirstResponder()
        }

        // MARK: Public

        public var form: TextForm?

        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return form?.inputStyle.isKindOfPicker != true ?? true
        }

        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            return originalDelegate?.textFieldShouldBeginEditing?(textField) ?? true
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            originalDelegate?.textFieldDidBeginEditing?(textField)
        }

        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            return originalDelegate?.textFieldShouldEndEditing?(textField) ?? true
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            originalDelegate?.textFieldDidEndEditing?(textField)
        }

        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            originalDelegate?.textFieldDidEndEditing?(textField, reason: reason)
        }

        public func textFieldDidChangeSelection(_ textField: UITextField) {
            originalDelegate?.textFieldDidChangeSelection?(textField)
        }

        public func textFieldShouldClear(_ textField: UITextField) -> Bool {
            return originalDelegate?.textFieldShouldClear?(textField) ?? true
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return originalDelegate?.textFieldShouldReturn?(textField) ?? true
        }

        @available(iOS 16.0, *)
        public func textField(_ textField: UITextField, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
            originalDelegate?.textField?(textField, editMenuForCharactersIn: range, suggestedActions: suggestedActions)
        }

        @available(iOS 16.0, *)
        public func textField(_ textField: UITextField, willPresentEditMenuWith animator: any UIEditMenuInteractionAnimating) {
            originalDelegate?.textField?(textField, willPresentEditMenuWith: animator)
        }

        @available(iOS 16.0, *)
        public func textField(_ textField: UITextField, willDismissEditMenuWith animator: any UIEditMenuInteractionAnimating) {
            originalDelegate?.textField?(textField, willDismissEditMenuWith: animator)
        }

        // MARK: Internal

        var originalDelegate: (any UITextFieldDelegate)?

        // MARK: Private

        private var coverView = UIView()

        private func setupCoverView() {
            if let superview {
                superview.addSubview(coverView)
                coverView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    coverView.topAnchor.constraint(equalTo: topAnchor),
                    coverView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    coverView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    coverView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
                coverView.isHidden = true
            }
        }
    }

    open var isRequired: Bool

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

        // MARK: Internal

        var isKindOfPicker: Bool {
            switch self {
            case .text:
                return false
            case .datePicker, .picker:
                return true
            }
        }
    }

    public struct PickerContext {
        // MARK: Lifecycle

        public init(titles: [String], initialSelection: Int? = nil) {
            self.titles = titles
            if let initialSelection {
                self.initialSelection = max(0, min(titles.count - 1, initialSelection))
            }
            else {
                self.initialSelection = nil
            }
        }

        // MARK: Public

        public let titles: [String]
        public let initialSelection: Int?

        public var initialTitle: String? {
            guard let initialSelection else {
                return nil
            }
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

        public var isEmpty: Bool {
            return count == 0
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

    public func bind(_ cell: TextFormCell) -> AnyCancellable {
        cell.inputField.form = self
        cell.inputField.placeholder = placeholder
        switch inputStyle {
        case let .text(_, context):
            cell.inputField.isSecureTextEntry = context.isSecureText
            cell.inputField.keyboardType = context.keyboardType
            cell.inputField.spellCheckingType = context.spellCheckingType
            cell.inputField.autocorrectionType = context.autocorrectionType
            cell.inputField.autocapitalizationType = context.autocapitalizationType
        case .picker:
            cell.inputField.inputView = currentPickerView()
        case .datePicker:
            cell.inputField.inputView = currentDatePicker()
        }
        return $currentInput
            .map { $0?.toString() }
            .assign(to: \UITextField.text, on: cell.inputField)
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
                if let initialSelection = context.initialSelection {
                    picker.selectRow(initialSelection, inComponent: 0, animated: false)
                }
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
