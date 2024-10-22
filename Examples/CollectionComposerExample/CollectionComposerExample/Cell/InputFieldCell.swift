//
//  InputFieldCell.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/10/21.
//

import CollectionComposer
import Combine
import UIKit

class InputFieldCell: UICollectionViewCell, @preconcurrency TextFormCell {
    // MARK: Public

    public var form: TextForm?

    // MARK: Internal

    static let defaultTextFieldHeight: CGFloat = 39
    static let defaultHeight: CGFloat = 60

    func configure(_ form: CollectionComposer.TextForm) {
        cancellable.removeAll()
        self.form = form
        form.$currentInput.map { $0?.toString() }
            .assign(to: \UITextField.text, on: textField)
            .store(in: &cancellable)

        label.isHidden = form.label == nil
        if let labelText = form.label, labelText.isEmpty {
            label.isHidden = true
        }
        label.text = form.label
        textField.configure(form: form).store(in: &cancellable)
        form.shouldFocusTextFieldPublisher.sink { [weak self] _ in
            guard let self else {
                return
            }
            textField.becomeFirstResponder()
        }.store(in: &cancellable)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: Private

    @IBOutlet private var label: UILabel!
    @IBOutlet private var textField: UITextField!
    private var cancellable = Set<AnyCancellable>()
}
