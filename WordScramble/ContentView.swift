//
//  ContentView.swift
//  WordScramble
//
//  Created by Ram Mhapasekar on 11/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var definationWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    @StateObject private var viewModel = WordViewModel()
    
    var body: some View {
        NavigationStack {
            List{
                Section(header: Text("Defination : \(getDefination(word: rootWord))")){
//              Section(){
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(usedWords.indices, id: \.self){ index in
                        let word = usedWords[index]
                        VStack{
                            HStack{
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            Text("Defination : \(definationWords[index])")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError){
                Button("OK"){}
            }message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word not original", message: "You have already used this word")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "The letters in \(answer) are not in \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not real", message: "\(answer) is not a real word")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
            let def = getDefination(word: answer)
            definationWords.insert(def, at: 0)
            
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: startWordURL) {
                let allWords = startWord.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt word")
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func getDefination(word: String) -> String{
        if let result = viewModel.definition(for: word) {
            return result
        } else {
            return "Definition not found."
        }
    }
    
    func wordError(title:String, message: String){
        errorTitle = title
        errorMessage = message
        self.showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
