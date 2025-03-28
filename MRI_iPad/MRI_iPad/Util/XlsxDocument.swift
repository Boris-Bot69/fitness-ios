//
//  XlsxDocument.swift
//  DoctorsApp
//
//  Created by Benedikt Strobel on 08.07.21.
//
//swiftlint:disable force_unwrapping

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class XlsxDocument: FileDocument {
    static let xlsxType = UTType(filenameExtension: "xlsx", conformingTo: .data)!
    let byteData: Data
    let fileName: String?
    
    static var readableContentTypes: [UTType] {
        [xlsxType]
    }
    
    static var writableContentTypes: [UTType] {
        [xlsxType]
    }
    
    required init(configuration: FileDocumentReadConfiguration) throws {
        if let readData = configuration.file.regularFileContents {
            self.byteData = readData
            fileName = configuration.file.filename
        } else {
            self.byteData = Data()
            fileName = nil
        }
    }
    
    init(byteData: Data, fileName: String?) {
        self.byteData = byteData
        self.fileName = fileName
    }
    
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: byteData)
        fileWrapper.filename = fileName
        return fileWrapper
    }
}
