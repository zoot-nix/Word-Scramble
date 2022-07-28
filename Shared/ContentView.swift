//
//  ContentView.swift
//  Shared
//
//  Created by Owais Shaikh on 04/07/22.
//

import SwiftUI

struct ContentView: View {
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UITableView.appearance().backgroundColor = .clear
        }
    
    let bgColor : Color = Color(red: 221/255, green: 202/255, blue: 187/255)
    let navColor : Color = Color(red: 74/255, green: 38/255, blue: 28/255)
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    //Alert Dialog
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var ShowingError = false
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                .listRowBackground(Color(red: 173/255, green: 202/255, blue: 255/255))//blue
                
                Section("Words Guessed"){
                    ForEach(usedWords, id:\.self){
                        word in
                        HStack{
                            Text(word)
                            Spacer()
                            Image(systemName: "\(word.count).circle")
                        }
                    }
                }
                .listRowBackground(Color(red: 181/255, green: 241/255, blue: 208/255))//green
                
            }
            .background(bgColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Text(rootWord.capitalized)
                        .font(.largeTitle.bold())
                        .foregroundColor(navColor)
                        .accessibilityAddTraits(.isHeader)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        StartGame()
                    }, label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .foregroundColor(navColor)
                    })
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: StartGame)
            .alert(errorTitle, isPresented: $ShowingError){
                Button("OK", role: .cancel){}
            }message:{
                Text(errorMessage)
            }
            
        }
    }
    
    //Adds new word to the list and empties the var->newWord
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        // More Validation
        guard OriginalWord(word: answer) else{
            wordError(title: "Word used already!!", message: "Try something new")
            return
        }
        
        guard isValidWord(word: answer) else{
            wordError(title: "Word not possible!", message: "You can't spell that word from '\(rootWord)'")
            return
        }
            
        guard isRealWord(word: answer) else{
                wordError(title: "Word not recognized!", message: "Don't use your own made-up words")
            return
        }
        
        guard wordLength(word: answer) else{
            wordError(title: "Too Short!", message: "Try words with 3 or more characters")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    //Start Game
    func StartGame(){
        usedWords = []
        if let wordListURL = Bundle.main.url(forResource: "WordList", withExtension: "txt"){
            if let wordList = try? String(contentsOf: wordListURL){
                let allWords = wordList.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "accident"
                return
            }
        }
        fatalError("Could not load WordList.txt from Bundle.")
    }
    
    //Check Duplicate words in guesses
    func OriginalWord(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    //Check if guessed letter corresponds to letter in rootWord
    func isValidWord(word:String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    //Check if guessed word exists in eng-vocabulary
    func isRealWord(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    //Check Word Length
    func wordLength(word: String) -> Bool{
        if word.count <= 2{
            return false
        }else{
            return true
        }
    }
    
    //Alert Box
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        ShowingError = true
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
