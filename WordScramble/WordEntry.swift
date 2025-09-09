//
//  WordEntry.swift
//  WordScramble
//
//  Created by RamUttam Mhapasekar on 15/08/2025.
//

import Foundation

struct WordEntry: Codable, Identifiable {
    var id: String { word ?? UUID().uuidString }
    let word: String?
    let definition: String?
}
