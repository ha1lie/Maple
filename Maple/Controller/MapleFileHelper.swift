//
//  MapleFileHelper.swift
//  Maple
//
//  Created by Hallie on 4/16/22.
//

import Foundation

class MapleFileHelper {
    static let shared: MapleFileHelper = MapleFileHelper()
    
    private let fManager: FileManager = .default
    
    /// Writes contents to given location
    /// - Parameters:
    ///   - contents: Contents to be written
    ///   - loc: Location to write the file(including filename)
    public func writeFile(withContents contents: String, atLocation loc: URL) {
        if self.fManager.fileExists(atPath: self.urlToString(loc)) {
            try? self.fManager.removeItem(at: loc)
        }
        
        self.fManager.createFile(atPath: self.urlToString(loc), contents: contents.data(using: .utf8))
    }
    
    /// Reads a file at a location
    /// - Parameter loc: Location of file to read
    /// - Returns: String representation of the file contents
    public func readFile(atLocation loc: URL) -> String? {
        do {
            let result = String(data: try Data(contentsOf: loc), encoding: .utf8)
            return result
        } catch {
            return ""
        }
    }
    
    /// Gets the contents of a given directory
    /// - Parameter dir: Directory to check
    /// - Returns: The contents of this directory
    public func contentsOf(Directory dir: URL) -> [String] {
        do {
            let contents = try self.fManager.contentsOfDirectory(atPath: self.urlToString(dir))
            return contents
        } catch {
            return []
        }
    }
    
    /// Gets the String of a URL
    /// - Parameter url: URL to stringify
    /// - Returns: The string's representation of given URL
    public func urlToString(_ url: URL) -> String {
        return url.absoluteString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
}

enum FileError: Error {
    case notDirectory
}
