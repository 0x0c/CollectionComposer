//
//  InputField.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/11/03.
//

import UIKit

/// A customizable text input field with additional focus management and picker-related behavior.
///
/// `InputField` extends `UITextField` to provide advanced input behavior, such as displaying a hidden overlay view
/// when a picker input is in use, and delegating focus changes to a `TextForm`. It also supports handling
/// `UITextFieldDelegate` methods through an `originalDelegate`.
///
/// This class is useful for applications that require custom handling of keyboard input, picker display,
/// and focused/unfocused state transitions.
///
/// ### Usage
/// ```swift
/// let inputField = InputField()
/// inputField.form = textForm
/// inputField.originalDelegate = self
/// ```
///
/// - Note: This class implements `UITextFieldDelegate` and handles its own delegate methods internally.
open class InputField: UITextField, UITextFieldDelegate {
    // MARK: Open

    // MARK: Open Properties

    /// A reference to the original delegate, allowing custom behavior for delegate methods.
    open var originalDelegate: (any UITextFieldDelegate)?

    /// Called to layout subviews and setup the cover view for picker inputs.
    ///
    /// This method sets the delegate to `self` and ensures that the cover view is added to the superview
    /// if it has not been set up yet.
    override open func layoutSubviews() {
        super.layoutSubviews()
        delegate = self
        if coverView.superview == nil {
            setupCoverView()
        }
    }

    // MARK: Open Methods

    /// Returns the caret rectangle, or hides it if the input style is set to picker.
    override open func caretRect(for position: UITextPosition) -> CGRect {
        if let form, form.inputStyle.isKindOfPicker {
            return .zero
        }
        return super.caretRect(for: position)
    }

    /// Returns selection rectangles, or hides them if the input style is set to picker.
    override open func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        if let form, form.inputStyle.isKindOfPicker {
            return []
        }
        return super.selectionRects(for: range)
    }

    /// Determines if an action can be performed, disallowing it if the input style is set to picker.
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let form, form.inputStyle.isKindOfPicker {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

    /// Becomes the first responder and shows the cover view if input style is picker.
    ///
    /// - Returns: A Boolean indicating whether the field became the first responder.
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        if let form, form.inputStyle.isKindOfPicker {
            coverView.isHidden = false
        }
        else {
            coverView.isHidden = true
        }

        if let form, let handler = form.focusedHandler {
            handler(form)
        }

        if let form {
            switch form.inputStyle {
            case let .datePicker(context):
                if case let .date(date, _) = form.currentInput, date == nil {
                    form.currentInput = .date(form.currentDatePicker()?.date, context.formatter)
                }
            case let .picker(context):
                if form.currentInput == nil,
                   let index = form.currentPickerView()?.selectedRow(inComponent: 0),
                   index < context.titles.count {
                    form.currentInput = .picker(context.titles[index])
                }
            default:
                break
            }
        }
        return super.becomeFirstResponder()
    }

    /// Resigns the first responder status and hides the cover view.
    ///
    /// - Returns: A Boolean indicating whether the field resigned as the first responder.
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        coverView.isHidden = true
        if let form, let handler = form.resignedHandler {
            handler(form)
        }
        return super.resignFirstResponder()
    }

    // MARK: Public

    // MARK: Public Properties

    /// A reference to the associated `TextForm`, used for managing focus and handling picker input.
    public var form: TextForm?

    // MARK: UITextFieldDelegate Methods

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return form?.inputStyle.isKindOfPicker != true ?? true
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return originalDelegate?.textFieldShouldBeginEditing?(textField) ?? form?.showKeyboard ?? true
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

    // MARK: Private

    // MARK: Private Properties

    /// An overlay view that hides the caret and selection for picker-based input.
    private var coverView = UIView()

    // MARK: Private Methods

    /// Sets up the cover view and adds it to the superview, covering the entire text field.
    ///
    /// The cover view is used to prevent the caret and text selection from appearing when the input style is a picker.
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
