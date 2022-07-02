//
//  LogFile.swift
//  Maple
//
//  Created by Hallie on 6/30/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct LogFile: FileDocument {
    static var readableContentTypes: [UTType] = [.log]
    
    var content: String = ""
    
    init(initialText: String = "") {
        content = initialText
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8)
        return FileWrapper(regularFileWithContents: data!)
    }
}
