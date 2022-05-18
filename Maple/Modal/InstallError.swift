//
//  InstallError.swift
//  Maple
//
//  Created by Hallie on 5/17/22.
//

import Foundation

enum InstallError: Error, CustomStringConvertible {
    case fileDidntExist
    case compressionError
    case invalidSap
    case invalidDirectories
    case unknown
    
    var description: String {
        switch self {
        case .fileDidntExist:
            return "Couldn't find a file which we expected to exist. Ensure all file names are correct, and where they belong"
        case .compressionError:
            return "Failed to decompress .mapleleaf file. Ensure all compression is correct"
        case .invalidDirectories:
            return "Invalid folder structure. Ensure all names are correct"
        case .invalidSap:
            return "Invalid .sap file. Ensure all words and encoding"
        case .unknown:
            return "Unknown error. Contact developer"
        }
    }
}
