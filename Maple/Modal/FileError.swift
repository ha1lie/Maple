//
//  FileError.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import Foundation

/// Errors relating to file actions
enum FileError: Error {
    /// Certain URLs must point to a directory
    case notDirectory
}
