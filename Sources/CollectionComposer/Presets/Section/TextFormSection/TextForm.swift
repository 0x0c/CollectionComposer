//
//  TextForm.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/03.
//

import Combine
import UIKit

// MARK: - TextForm

/// A configurable form input supporting text, date pickers, and selection pickers.
///
/// `TextForm` allows flexible handling of form-based input within collection views or other UI components.
/// It supports required fields, secure text entry, validation, and focus management, allowing for complex form flows.
open class TextForm: NSObject {
    // MARK: Lifecycle

    /// Initializes a new `TextForm` instance with specified properties.
    ///
    /// - Parameters:
    ///   - label: The label displayed for the form field. Defaults to `nil`.
    ///   - placeholder: The placeholder text displayed in the input field. Defaults to `nil`.
    ///   - isRequired: A Boolean indicating if the field is required. Defaults to `false`.
    ///   - inputStyle: The style of input for the form (e.g., text, date picker, or selection picker). Defaults to `.text(nil, TextInputContext())`.
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
            currentInput = context.initialSelection == nil ? nil : .picker(context.initialTitle)
        }
    }

    /// Convenience initializer for creating a text-based form with additional configuration.
    ///
    /// - Parameters:
    ///   - label: The label displayed for the form field. Defaults to `nil`.
    ///   - text: The initial text to display in the form field. Defaults to `nil`.
    ///   - placeholder: The placeholder text displayed in the input field. Defaults to `nil`.
    ///   - isRequired: A Boolean indicating if the field is required. Defaults to `false`.
    ///   - isSecureText: A Boolean indicating if the text should be securely hidden. Defaults to `false`.
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

    /// A Boolean indicating whether the form input is required.
    open var isRequired: Bool

    /// A Boolean indicating whether the current input is valid, based on validation rules.
    open var isValid: Bool {
        return validate() == .valid
    }

    /// Configures a custom validation handler for the form.
    ///
    /// - Parameter handler: A closure that takes the current input and returns a `ValidationResult`.
    /// - Returns: The configured `TextForm` instance.
    @discardableResult
    open func validation(_ handler: @escaping (Input?) -> ValidationResult) -> Self {
        validationHandler = handler
        return self
    }

    /// Moves focus to the next form input in the linked form sequence.
    ///
    /// - Returns: A Boolean indicating if the focus successfully moved to the next input.
    @discardableResult
    open func focuseNext() -> Bool {
        guard let next else {
            return false
        }
        next._shouldFocusTextFieldSubject.send(())
        return true
    }

    /// Moves focus to the previous form input in the linked form sequence.
    ///
    /// - Returns: A Boolean indicating if the focus successfully moved to the previous input.
    @discardableResult
    open func focusePrevious() -> Bool {
        guard let previous else {
            return false
        }
        previous._shouldFocusTextFieldSubject.send(())
        return true
    }

    // MARK: Public

    /// Represents the various input styles available for a form, including text, date picker, and selection picker.
    public enum InputStyle {
        /// A standard text input with optional secure text configuration.
        case text(String?, TextInputContext)

        /// A date picker input with optional initial date and formatter settings.
        case datePicker(DatePickerContext = DatePickerContext())

        /// A picker input with an array of selectable titles and optional initial selection.
        case picker(PickerContext)

        // MARK: Public

        /// A Boolean indicating if the input style is a picker type (either date picker or selection picker).
        public var isKindOfPicker: Bool {
            switch self {
            case .text:
                return false
            case .datePicker, .picker:
                return true
            }
        }

        // MARK: Internal

        var inputKind: InputKind {
            switch self {
            case .text:
                return .text
            case .picker:
                return .picker
            case .datePicker:
                return .datePicker
            }
        }
    }

    /// Configuration for selection picker inputs, including selectable titles and an optional initial selection.
    public struct PickerContext {
        // MARK: Lifecycle

        /// Initializes a picker context with the specified titles and optional initial selection.
        ///
        /// - Parameters:
        ///   - titles: The titles for picker options.
        ///   - initialSelection: The index of the initially selected option, if any.
        public init(titles: [String], initialSelection: Int? = nil) {
            self.titles = titles
            self.initialSelection = initialSelection.map { max(0, min(titles.count - 1, $0)) }
        }

        // MARK: Public

        /// The list of titles available for selection in the picker.
        public let titles: [String]

        /// The index of the initially selected option, if any.
        public let initialSelection: Int?

        /// The title of the initially selected option, if any.
        public var initialTitle: String? {
            guard let initialSelection else {
                return nil
            }
            return titles.count > initialSelection ? titles[initialSelection] : nil
        }
    }

    /// Configuration for date picker inputs, including an initial date, display mode, and date formatter.
    public struct DatePickerContext {
        // MARK: Lifecycle

        /// Initializes a date picker context with an optional initial date, display mode, and formatter.
        ///
        /// - Parameters:
        ///   - initialDate: The initial date for the picker, if any.
        ///   - mode: The display mode of the date picker. Defaults to `.date`.
        ///   - formatter: A formatter for displaying the selected date, if any.
        public init(_ initialDate: Date? = nil, mode: UIDatePicker.Mode = .date, formatter: DateFormatter? = nil) {
            self.initialDate = initialDate
            self.mode = mode
            self.formatter = formatter
        }

        // MARK: Public

        /// The initial date for the picker, if any.
        public let initialDate: Date?

        /// The mode of the date picker (e.g., date, time).
        public let mode: UIDatePicker.Mode

        /// The date formatter used for displaying the selected date.
        public let formatter: DateFormatter?
    }

    /// Configuration for text input fields, including secure text entry and keyboard settings.
    public struct TextInputContext {
        // MARK: Lifecycle

        /// Initializes a text input context with the specified configurations.
        ///
        /// - Parameters:
        ///   - isSecureText: A Boolean indicating if the text should be securely hidden. Defaults to `false`.
        ///   - keyboardType: The keyboard type to use. Defaults to `.default`.
        ///   - spellCheckingType: The spell-checking type to use. Defaults to `.default`.
        ///   - autocorrectionType: The autocorrection type to use. Defaults to `.default`.
        ///   - autocapitalizationType: The autocapitalization type to use. Defaults to `.none`.
        ///   - contentType: The content type hint for the input field, if any.
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

        /// A Boolean indicating if the text input should be secure (e.g., for passwords).
        public let isSecureText: Bool

        /// The keyboard type for the input field.
        public let keyboardType: UIKeyboardType

        /// The spell-checking type for the input field.
        public let spellCheckingType: UITextSpellCheckingType

        /// The autocorrection type for the input field.
        public let autocorrectionType: UITextAutocorrectionType

        /// The autocapitalization type for the input field.
        public let autocapitalizationType: UITextAutocapitalizationType

        /// The content type hint for the input field, if any.
        public let contentType: UITextContentType?
    }

    /// Represents the result of form validation.
    public enum ValidationResult: Equatable {
        /// The input is valid.
        case valid

        /// The input is invalid, with an optional hint message.
        case invalid(hint: String?)

        // MARK: Public

        public static func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
            switch (lhs, rhs) {
            case (.valid, .valid):
                return true
            case (.invalid, .invalid):
                return true
            default:
                return false
            }
        }
    }

    /// Represents the possible inputs in a form.
    public enum Input: Sendable {
        /// A text input.
        case text(String?)

        /// A selection from a picker.
        case picker(String?)

        /// A date selected from a date picker, with an optional formatter.
        case date(Date?, DateFormatter?)

        // MARK: Public

        /// A count of characters or values in the input.
        public var count: Int {
            switch self {
            case let .text(string):
                return string?.count ?? 0
            case let .picker(string):
                return string?.count ?? 0
            case let .date(date, _):
                return date == nil ? 0 : 1
            }
        }

        /// A Boolean indicating if the input is empty.
        public var isEmpty: Bool {
            return count == 0
        }

        /// Returns the input as a string, if applicable.
        public func toString() -> String? {
            switch self {
            case let .text(string):
                return string
            case let .picker(string):
                return string
            case let .date(date, formatter):
                if let date {
                    return formatter?.string(from: date) ?? date.description
                }
                return nil
            }
        }

        /// Returns the input as a date, if applicable.
        public func toDate() -> Date? {
            switch self {
            case .picker, .text:
                return nil
            case let .date(date, _):
                return date
            }
        }

        // MARK: Internal

        var inputKind: InputKind {
            switch self {
            case .text:
                return .text
            case .picker:
                return .picker
            case .date:
                return .datePicker
            }
        }
    }

    /// The style of input for the form, defining whether it is a text field, date picker, or selection picker.
    ///
    /// `inputStyle` determines the type of input used in the form. Depending on the value, the form can display
    /// a standard text input, a date picker, or a selection picker. This property is configured during initialization
    /// and is immutable after that.
    public let inputStyle: InputStyle

    /// A publisher that signals when the text field associated with the form should gain focus.
    ///
    /// This publisher is used to coordinate focus changes, especially when navigating between multiple `TextForm`
    /// instances. It is commonly triggered by the `focusNext` and `focusPrevious` methods.
    public lazy var shouldFocusTextFieldPublisher = _shouldFocusTextFieldSubject.eraseToAnyPublisher()

    /// The label displayed for the form field.
    ///
    /// `label` is an optional string that represents the title or label of the form field, displayed typically above
    /// or beside the input field. It provides users with context about the purpose of the form input.
    public var label: String?

    /// The current input value of the form.
    ///
    /// `currentInput` holds the data entered or selected by the user, such as text, a date, or a picker selection.
    /// It is marked as `@Published`, allowing it to be observed for changes, enabling reactive UI updates.
    @Published public var currentInput: Input?

    /// The placeholder text displayed within the input field when it is empty.
    ///
    /// `placeholder` provides a hint or example input for the user, helping them understand what type of input is
    /// expected. It is displayed in a grayed-out font and disappears once the user begins entering text.
    public var placeholder: String?

    /// A handler that defines custom validation logic for the input.
    ///
    /// `validationHandler` is a closure that evaluates the validity of the current input. When provided, this handler
    /// is called to perform custom validation on the input and returns a `ValidationResult`, indicating whether
    /// the input meets specified criteria.
    public var validationHandler: ((Input?) -> ValidationResult)?

    /// Sets whether the keyboard should be shown for this form.
    ///
    /// - Parameter showKeyboard: A Boolean that indicates if the keyboard should be displayed.
    /// - Returns: The configured `TextForm` instance.
    public func allowsToShowKeyboard(_ showKeyboard: Bool) -> TextForm {
        self.showKeyboard = showKeyboard
        return self
    }

    /// Binds the form to a `TextFormCell`, syncing its data and behavior.
    ///
    /// - Parameter cell: The `TextFormCell` to bind to this form.
    /// - Returns: A `AnyCancellable` instance managing the subscription.
    public func bind(_ cell: TextFormCell) -> AnyCancellable {
        cell.inputField.form = self
        inputField = cell.inputField

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
        let inputKind = inputStyle.inputKind
        let inputStyle = inputStyle
        return $currentInput.filter { newInput in
            if newInput?.inputKind == .picker,
               case let .picker(context) = inputStyle,
               case let .picker(text) = newInput {
                return context.titles.contains { $0 == text }
            }
            else {
                return newInput?.inputKind == inputKind
            }
        }.sink { [weak cell] input in
            guard let cell else {
                return
            }
            cell.inputField.text = input?.toString()
        }
    }

    /// Sets a handler to trigger when the form gains focus.
    ///
    /// - Parameter handler: The handler to trigger on focus.
    /// - Returns: The configured `TextForm` instance.
    public func onFocused(_ handler: @escaping (TextForm) -> Void) -> TextForm {
        focusedHandler = handler
        return self
    }

    /// Sets a handler to trigger when the form loses focus.
    ///
    /// - Parameter handler: The handler to trigger on loss of focus.
    /// - Returns: The configured `TextForm` instance.
    public func onResigned(_ handler: @escaping (TextForm) -> Void) -> TextForm {
        resignedHandler = handler
        return self
    }

    /// Retrieves or initializes a `UIDatePicker` for date input if the input style is set to `datePicker`.
    ///
    /// This method checks if the `inputStyle` is `.datePicker` and returns an existing `UIDatePicker` if available.
    /// If a `UIDatePicker` does not already exist, a new one is created, configured with the initial date, date picker mode,
    /// and an event listener for value changes.
    ///
    /// - Returns: An optional `UIDatePicker` if the input style is set to `datePicker`; otherwise, `nil`.
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

    /// Retrieves or initializes a `UIPickerView` for selection input if the input style is set to `picker`.
    ///
    /// This method checks if the `inputStyle` is `.picker` and returns an existing `UIPickerView` if available.
    /// If a `UIPickerView` does not already exist, a new one is created, configured with the specified titles,
    /// and the initial selection is set if provided.
    ///
    /// - Returns: An optional `UIPickerView` if the input style is set to `picker`; otherwise, `nil`.
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

    /// Makes the input field of the form become the first responder.
    ///
    /// This method attempts to give focus to the input field, typically resulting in the display of the keyboard
    /// or relevant input view.
    ///
    /// - Returns: A Boolean indicating whether the input field successfully became the first responder.
    @discardableResult
    public func becomeInputFieldFirstResponder() -> Bool {
        return inputField?.becomeFirstResponder() ?? false
    }

    /// Resigns the input field of the form as the first responder.
    ///
    /// This method removes focus from the input field, typically resulting in the keyboard or relevant input view
    /// being dismissed.
    ///
    /// - Returns: A Boolean indicating whether the input field successfully resigned as the first responder.
    @discardableResult
    public func resignInputFieldFirstResponder() -> Bool {
        return inputField?.resignFirstResponder() ?? false
    }

    // MARK: Internal

    enum InputKind {
        case text
        case picker
        case datePicker
    }

    var next: TextForm?
    var previous: TextForm?

    var showKeyboard: Bool = true
    var focusedHandler: ((TextForm) -> Void)?
    var resignedHandler: ((TextForm) -> Void)?

    func validate() -> ValidationResult {
        if let validationHandler {
            return validationHandler(currentInput)
        }
        if isRequired {
            return currentInput?.isEmpty == false ? .valid : .invalid(hint: "Form (label: \(label)) is requred but input is empty or nil.")
        }
        return .valid
    }

    // MARK: Private

    private var inputField: InputField?

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
            currentInput = .picker(context.titles[row])
        }
    }
}
