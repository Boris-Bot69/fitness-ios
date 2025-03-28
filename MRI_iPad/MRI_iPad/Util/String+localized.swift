//
//  String+localized.swift
//
//
//  Created by Jannis Mainczyk on 22.06.21.
//  Copied  by Benedikt Strobel on 23.06.21
//
// We know that we should only pass literal Strings into NSLocalizedString
// swiftlint:disable nslocalizedstring_key

// Needs to be duplicate (instead of imported from shared) because otherwise
// the Localizable.strings of shared would be used

import Foundation

extension String {
    /// Localization helper for strings in `DoctorsApp` package
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension String {
    func removeAllWhitespaces() -> String { self.filter { !$0.isWhitespace } }
}
