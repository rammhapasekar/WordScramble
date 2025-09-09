//
//  WordViewModel.swift
//  WordScramble
//
//  Created by RamUttam Mhapasekar on 15/08/2025.
//

import SwiftUI

class WordViewModel: ObservableObject {
    @Published var usedWords: [WordEntry] = []
    @Published var rootWord: String = ""
    @Published var error: WordError?
    @Published var entries: [WordEntry] = []
    private var allWords: [String] = []
    
    init() {
        loadRootWords()
        loadJSON("dict")
    }
    
    func loadJSON(_ filename: String) {
        //        guard let url = Bundle.main.url(forResource: "dict", withExtension: "json"),
        //              let data = try? Data(contentsOf: url),
        //              let decoded = try? JSONDecoder().decode([WordEntry].self, from: data) else {
        //            print("Failed to load or decode JSON.")
        //            return
        //        }
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to locate \(filename).json in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(filename).json from bundle.")
        }
        
        do {
            let entries = try JSONDecoder().decode([WordEntry].self, from: data)
            self.entries = entries
        } catch {
            print("Failed to decode dict.json: \(error)")
            return
        }
    }
    
    func loadRootWords() {
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            allWords = content.components(separatedBy: "\n")
            rootWord = allWords.randomElement() ?? "silkworm"
        } else {
            rootWord = "silkworm"
        }
    }
    
    func addNewWord(_ word: String) {
        let answer = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return }
        
        guard isOriginal(word: answer) else {
            error = .notOriginal
            return
        }
        guard isPossible(word: answer) else {
            error = .notPossible(answer: answer, root: rootWord)
            return
        }
        guard isReal(word: answer) else {
            error = .notReal(answer: answer)
            return
        }
        
        let definition = definition(for: answer) ?? "Definition not found."
        usedWords.insert(WordEntry(word: answer, definition: definition), at: 0)
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains { $0.word == word }
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func definition(for word: String) -> String? {
        // If you have a JSON file with definitions, load and search here.
        // Otherwise, return nil or a default message.
        entries.first { $0.word?.lowercased() == word.lowercased() }?.definition
    }
}

enum WordError: Identifiable {
    case notOriginal
    case notPossible(answer: String, root: String)
    case notReal(answer: String)
    
    var id: String { String(describing: self) }
    var title: String {
        switch self {
        case .notOriginal: return "Word not original"
        case .notPossible: return "Word not possible"
        case .notReal: return "Word not real"
        }
    }
    var message: String {
        switch self {
        case .notOriginal: return "You have already used this word."
        case .notPossible(let answer, let root): return "The letters in \(answer) are not in \(root)."
        case .notReal(let answer): return "\(answer) is not a real word."
        }
    }
}

//class WordViewModel: ObservableObject {
//    @Published var entries: [WordEntry] = []
//
//    init() {
//        loadJSON()
//    }
//
//    func loadJSON() {
//        guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
//              let data = try? Data(contentsOf: url),
//              let decoded = try? JSONDecoder().decode([WordEntry].self, from: data) else {
//            print("Failed to load or decode JSON.")
//            return
//        }
//        self.entries = decoded
//    }
//
//    func definition(for word: String) -> String? {
//        entries.first { $0.word.lowercased() == word.lowercased() }?.definition
//    }
//}
