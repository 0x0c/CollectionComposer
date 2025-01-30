//
//  TextForm.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/03/03.
//

import Combine
import UIKit

// MARK: - TextFormNotification

enum TextFormNotification {
    static let textFormKey = "CollectionComposer.TextFormNotification.textFormKey"
    static let willBeginEditingWithExternalInputMethod = Notification.Name("CollectionComposer.TextFormNotification.willBeginEditingWithExternalInputMethod")
}

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
            if let initialText {
                currentInput = .text(initialText)
            }
        case let .datePicker(context):
            if let date = context.initialDate {
                currentInput = .date(date)
            }
        case let .picker(context):
            if let initialInput = context.initialSelection == nil ? nil : context.initialItem {
                currentInput = .picker(initialInput)
            }
        case let .externalInput(initialText, _):
            if let initialText {
                currentInput = .text(initialText)
            }
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
    open func validation(_ handler: @escaping (TextForm, Input?) -> ValidationResult) -> Self {
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

        /// A picker input with an external input method.
        case externalInput(String?, ExternalInputHandler)

        // MARK: Public

        public typealias ExternalInputHandler = (String?) -> Void

        /// A Boolean indicating if the input style is a picker type (either date picker or selection picker).
        public var needsKeyboard: Bool {
            switch self {
            case .datePicker, .externalInput, .picker:
                return false
            default:
                return true
            }
        }

        // MARK: Internal

        var inputKind: InputKind {
            switch self {
            case .externalInput, .text:
                return .text
            case .picker:
                return .picker
            case .datePicker:
                return .datePicker
            }
        }
    }

    public protocol PickerItem {
        var collectionComposerPickerItemTitle: String { get }
    }

    /// Configuration for selection picker inputs, including selectable titles and an optional initial selection.
    public struct PickerContext {
        // MARK: Lifecycle

        /// Initializes a picker context with the specified titles and optional initial selection.
        ///
        /// - Parameters:
        ///   - titles: The titles for picker options.
        ///   - initialSelection: The index of the initially selected option, if any.
        public init(items: [any PickerItem], initialSelection: Int? = nil) {
            self.items = items
            self.initialSelection = initialSelection.map { max(0, min(items.count - 1, $0)) }
        }

        // MARK: Public

        /// The list of titles available for selection in the picker.
        public let items: [any PickerItem]

        /// The index of the initially selected option, if any.
        public let initialSelection: Int?

        /// The title of the initially selected option, if any.
        public var initialItem: (any PickerItem)? {
            guard let initialSelection else {
                return nil
            }
            return items.count > initialSelection ? items[initialSelection] : nil
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
        public init(
            _ initialDate: Date? = nil,
            mode: UIDatePicker.Mode = .date,
            minimumDate: Date? = nil,
            maximumDate: Date? = nil,
            minuteInterval: Int? = nil,
            countDownDuration: TimeInterval? = nil,
            roundsToMinuteInterval: Bool? = nil,
            formatter: DateFormatter? = nil
        ) {
            self.initialDate = initialDate
            self.mode = mode
            self.minimumDate = minimumDate
            self.maximumDate = maximumDate
            self.minuteInterval = minuteInterval
            self.countDownDuration = countDownDuration
            self.roundsToMinuteInterval = roundsToMinuteInterval
            self.formatter = formatter
        }

        // MARK: Public

        /// The initial date for the picker, if any.
        public let initialDate: Date?

        /// The mode of the date picker (e.g., date, time).
        public let mode: UIDatePicker.Mode

        /// The minimum date that a date picker can show.
        ///
        /// If not specified, the default value of UIDatePicker is used.
        public let minimumDate: Date?

        /// The maximum date that a date picker can show.
        ///
        /// If not specified, the default value of UIDatePicker is used.
        public let maximumDate: Date?

        /// The interval at which the date picker should display minutes.
        ///
        /// If not specified, the default value of UIDatePicker is used.
        public let minuteInterval: Int?

        /// The value displayed by the date picker when the mode property is set to show a countdown time.
        ///
        /// If not specified, the default value of UIDatePicker is used.
        public let countDownDuration: TimeInterval?

        /// A Boolean value that determines whether the date rounds to a specific minute interval.
        ///
        /// If not specified, the default value of UIDatePicker is used.
        public let roundsToMinuteInterval: Bool?

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
        case text(String)

        /// A selection from a picker.
        case picker(any PickerItem)

        /// A date selected from a date picker, with an optional formatter.
        case date(Date)

        // MARK: Public

        /// A count of characters or values in the input.
        public var count: Int {
            switch self {
            case let .text(string):
                return string.count ?? 0
            case let .picker(item):
                return item.collectionComposerPickerItemTitle.count ?? 0
            case let .date(date):
                return 1
            }
        }

        /// A Boolean indicating if the input is empty.
        public var isEmpty: Bool {
            return count == 0
        }

        /// Returns the input as a date, if applicable.
        public func toDate() -> Date? {
            switch self {
            case .picker, .text:
                return nil
            case let .date(date):
                return date
                return nil
            }
        }

        /// Returns the input as a picker item, if applicable.
        public func toPickerItem() -> (any PickerItem)? {
            switch self {
            case .date, .text:
                return nil
            case let .picker(item):
                return item
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

        func toString(_ formatter: DateFormatter? = nil) -> String {
            switch self {
            case let .text(string):
                return string
            case let .picker(item):
                return item.collectionComposerPickerItemTitle
            case let .date(date):
                return formatter?.string(from: date) ?? date.description
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
    public var validationHandler: ((TextForm, Input?) -> ValidationResult)?

    /// A publisher that sends the input value and the form when the current input is changed.
    public lazy var currentInputPublisher = currentInputSubject.eraseToAnyPublisher()

    /// The current input value of the form.
    ///
    /// `currentInput` holds the data entered or selected by the user, such as text, a date, or a picker selection.
    public var currentInput: Input? {
        didSet {
            currentInputSubject.send((input: currentInput, form: self))
        }
    }

    /// Returns the input as a string, if applicable.
    public func toString() -> String? {
        switch currentInput {
        case let .text(string):
            return string
        case let .picker(item):
            return item.collectionComposerPickerItemTitle
        case let .date(date):
            if let formatter = dateFormatter() {
                return formatter.string(from: date)
            }
            return date.description
        case .none:
            return nil
        }
    }

    /// Sets whether the keyboard should be shown for this form.
    ///
    /// - Parameter showKeyboard: A Boolean that indicates if the keyboard should be displayed.
    /// - Returns: The configured `TextForm` instance.
    public func allowsToShowKeyboard(_ showKeyboard: Bool) -> TextForm {
        allowsEditing = showKeyboard
        return self
    }

    /// Binds the form to a `TextFormCell`, syncing its data and behavior.
    ///
    /// - Parameter cell: The `TextFormCell` to bind to this form.
    /// - Returns: A `AnyCancellable` instance managing the subscription.
    @MainActor public func bind(_ cell: TextFormCell) -> AnyCancellable {
        prepareCell(cell)
        inputField?.text = toString()
        return currentInputPublisher.filter { update in
            if case let .picker(context) = update.form.inputStyle,
               case let .picker(item) = update.input {
                return context.items.contains { $0.collectionComposerPickerItemTitle == item.collectionComposerPickerItemTitle }
            }
            return true
        }.sink { [weak cell, weak self] _ in
            guard let cell, let self else {
                return
            }
            inputField?.text = toString()
            updateInputView()
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
                if let date = currentInput?.toDate() {
                    datePicker.date = date
                }
                return datePicker
            }
            else {
                let picker = UIDatePicker()
                if let initialDate = context.initialDate {
                    picker.date = initialDate
                }
                else if let date = currentInput?.toDate() {
                    picker.date = date
                }
                picker.addTarget(self, action: #selector(didDatePickerValueChange), for: .valueChanged)
                picker.preferredDatePickerStyle = .wheels
                picker.datePickerMode = context.mode
                if let minimumDate = context.minimumDate {
                    picker.minimumDate = minimumDate
                }
                if let maximumDate = context.maximumDate {
                    picker.maximumDate = maximumDate
                }
                if let minuteInterval = context.minuteInterval {
                    picker.minuteInterval = minuteInterval
                }
                if let countDownDuration = context.countDownDuration {
                    picker.countDownDuration = countDownDuration
                }
                if let roundsToMinuteInterval = context.roundsToMinuteInterval {
                    picker.roundsToMinuteInterval = roundsToMinuteInterval
                }
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
                else if let index = context.items.firstIndex(where: {
                    $0.collectionComposerPickerItemTitle == currentInput?.toPickerItem()?.collectionComposerPickerItemTitle
                }) {
                    picker.selectRow(index, inComponent: 0, animated: false)
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
        case externalInput
    }

    var next: TextForm?
    var previous: TextForm?

    var focusedHandler: ((TextForm) -> Void)?
    var resignedHandler: ((TextForm) -> Void)?

    var _allowsEditing = true

    var allowsEditing: Bool {
        get {
            if inputStyle.inputKind == .externalInput {
                return false
            }
            return _allowsEditing
        }
        set {
            if inputStyle.inputKind == .externalInput {
                return
            }
            _allowsEditing = newValue
        }
    }

    func validate() -> ValidationResult {
        if let validationHandler {
            return validationHandler(self, currentInput)
        }
        if isRequired {
            return currentInput?.isEmpty == false ? .valid : .invalid(hint: "Form (label: \(label)) is requred but input is empty or nil.")
        }
        return .valid
    }

    // MARK: Private

    private var currentInputSubject = PassthroughSubject<(input: Input?, form: TextForm), Never>()
    private var inputField: InputField?

    private var datePicker: UIDatePicker?

    private var pickerView: UIPickerView?

    private var _shouldFocusTextFieldSubject = PassthroughSubject<Void, Never>()
    private let id = UUID()

    @MainActor
    private func prepareCell(_ cell: TextFormCell) {
        inputField = cell.inputField
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
        case .externalInput:
            cell.inputField.inputView = nil
        }
    }

    @MainActor
    private func updateInputView() {
        switch (inputField?.inputView, currentInput, inputStyle) {
        case let (datePicker as UIDatePicker, .date(date), _):
            if datePicker.date != date {
                datePicker.setDate(date, animated: true)
            }
        case let (pickerView as UIPickerView, .picker(item), .picker(context)):
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            if let row = context.items
                .map(\.collectionComposerPickerItemTitle)
                .firstIndex(of: item.collectionComposerPickerItemTitle),
                selectedRow != row {
                pickerView.selectRow(row, inComponent: 0, animated: true)
            }
        default:
            break
        }
    }

    private func dateFormatter() -> DateFormatter? {
        guard case let .datePicker(context) = inputStyle else {
            return nil
        }
        return context.formatter
    }

    @objc
    private func didDatePickerValueChange(_ sender: UIDatePicker) {
        if case .datePicker = inputStyle {
            currentInput = .date(sender.date)
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
            return context.items.count
        }
        return 0
    }

    // MARK: - UIPickerViewDelegate

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if case let .picker(context) = inputStyle {
            return context.items[row].collectionComposerPickerItemTitle
        }
        return nil
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if case let .picker(context) = inputStyle {
            currentInput = .picker(context.items[row])
        }
    }
}
