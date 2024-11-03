//
//  InputField.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2024/11/03.
//

import UIKit

open class InputField: UITextField, UITextFieldDelegate {
    // MARK: Open

    open var originalDelegate: (any UITextFieldDelegate)?

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

    override open func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        if let form, form.inputStyle.isKindOfPicker {
            return []
        }
        return super.selectionRects(for: range)
    }

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let form, form.inputStyle.isKindOfPicker {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

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

    @discardableResult
    override open func resignFirstResponder() -> Bool {
        coverView.isHidden = true
        if let form, let handler = form.resignedHandler {
            handler(form)
        }
        return super.resignFirstResponder()
    }

    // MARK: Public

    public var form: TextForm?

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
