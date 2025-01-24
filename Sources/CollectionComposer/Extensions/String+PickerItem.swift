//
//  String+PickerItem.swift
//  CollectionComposer
//
//  Created by Akira Matsuda on 2025/01/24.
//

import Foundation

extension String: TextForm.PickerItem {
    public var collectionComposerPickerItemTitle: String { self }
}
