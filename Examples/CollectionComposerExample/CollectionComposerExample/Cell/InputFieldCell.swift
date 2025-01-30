//
//  InputFieldCell.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/10/21.
//

import CollectionComposer
import Combine
import UIKit

class InputFieldCell: UICollectionViewCell, @preconcurrency TextFormCell, UITextFieldDelegate {
    // MARK: Public

    public var form: TextForm?

    // MARK: Internal

    static let defaultTextFieldHeight: CGFloat = 39
    static let defaultHeight: CGFloat = 60

    var inputField: CollectionComposer.InputField { textField }

    func configure(_ form: CollectionComposer.TextForm) {
        cancellable.removeAll()
        self.form = form
        form.currentInputPublisher.map { input in
            return input.form.toFormattedString()
        }.assign(to: \UITextField.text, on: inputField)
            .store(in: &cancellable)

        label.isHidden = form.label == nil
        if let labelText = form.label, labelText.isEmpty {
            label.isHidden = true
        }
        label.text = form.label
        form.bind(self).store(in: &cancellable)
        form.shouldFocusTextFieldPublisher.sink { [weak self] _ in
            guard let self else {
                return
            }
            inputField.becomeFirstResponder()
        }.store(in: &cancellable)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Task { @MainActor in
            textFieldBaseView.layer.borderWidth = 1
            textFieldBaseView.layer.borderColor = UIColor.green.cgColor
            textFieldBaseView.translatesAutoresizingMaskIntoConstraints = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            textFieldBaseView.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: textFieldBaseView.topAnchor),
                textField.leadingAnchor.constraint(equalTo: textFieldBaseView.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: textFieldBaseView.trailingAnchor),
                textField.bottomAnchor.constraint(equalTo: textFieldBaseView.bottomAnchor)
            ])
        }
    }

    // MARK: Private

    @IBOutlet private var textFieldBaseView: UIView!

    @IBOutlet private var label: UILabel!
    private lazy var textField: InputField = {
        let textField = InputField(frame: .zero)
        textField.originalDelegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return textField
    }()

    private var cancellable = Set<AnyCancellable>()

    @objc private func textDidChange(_ textField: UITextField) {
        guard let form else {
            return
        }
        if form.inputStyle.needsKeyboard == false, let text = textField.text {
            form.currentInput = .text(text)
        }
    }
}
