//
//  TextHandler.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/18.
//
import Foundation

func loadTextFromBundle(filename: String) -> String? {
    // Get the path for the file in the bundle
    if let path = Bundle.main.path(forResource: filename, ofType: "txt") {
        do {
            // Read the file content
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return content
        } catch {
            print("Error loading file from bundle: \(error.localizedDescription)")
            return nil
        }
    } else {
        print("File not found in bundle.")
        return nil
    }
}
