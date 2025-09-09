//
//  ContentView.swift
//  WordScramble
//
//  Created by Ram Mhapasekar on 11/08/25.
//

import SwiftUI

struct ContentView: View {
  @State private var usedWord = [String]()
  @State private var rootWord = ""
  @State private var newWord = ""
  
  @State private var errorTitle = ""
  @State private var errorMessage = ""
  @State private var showingError = false

  var body: some View {
    NavigationStack {
      List {
        Section {
          TextField("Enter your word", text: $newWord)
            .textInputAutocapitalization(.never)
        }
        
        Section{
          ForEach(usedWord, id: \.self) { word in
            HStack {
              Image(systemName: "\(word.count).circle")
              Text(word)
            }
          }
        }
      }
      .navigationTitle(rootWord)
      .onSubmit(addNewWord)
      .onAppear(perform: startGame)
      .alert(errorTitle, isPresented: $showingError){
        Button("OK"){}
      }message: {
        Text(errorMessage)
      }
    }
  }
  
  func addNewWord(){
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard answer.count>0 else{return}
    guard isOringinal(word: answer) else{
      wordError(title: "Word used already", message: "Be more original")
      return
    }
    
    guard isPossible(word: answer) else {
      wordError(title: "word not possible", message: "You can't spell that word from '\(rootWord)'!")
      return
    }
    
    guard isReal(word: answer) else{
      wordError(title: "word not recognized", message: "Yoy can't just make them up.")
      return
    }
    
    withAnimation{
      usedWord.insert(answer, at: 0)
    }
    newWord = ""
  }
  
  func startGame(){
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
      if let startWords =  try? String(contentsOf: startWordsURL){
        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
        return
      }
    }
    fatalError("Could not load start.txt form bundle")
  }
  
  func isOringinal(word: String)-> Bool{
    !usedWord.contains(word)
  }
  
  func isPossible(word: String)-> Bool{
    var tempWord = rootWord
    for letter in word{
      if let pos  = tempWord.firstIndex(of: letter){
        tempWord.remove(at: pos)
      }
      else{
        return false
      }
    }
    return true
  }
  
  func isReal(word: String)-> Bool{
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    return misspellRange.location == NSNotFound
  }
  
  func wordError(title: String, message: String) {
    errorMessage = message
    errorTitle = title
    showingError = true
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
