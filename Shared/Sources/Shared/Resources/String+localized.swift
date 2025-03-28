//
//  String+localized.swift
//  
//
//  Created by Jannis Mainczyk on 22.06.21.
//
// We know that we should only pass literal Strings into NSLocalizedString
// swiftlint:disable nslocalizedstring_key

import Foundation

extension String {
    /// Localization helper for strings in `Shared` package
    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
}
