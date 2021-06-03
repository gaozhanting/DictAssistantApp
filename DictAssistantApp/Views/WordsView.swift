//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/22.
//

import SwiftUI
import DataBases

struct WordsView: View {
    @ObservedObject var modelData: ModelData
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "presentCount >= \(familiarThreshold)")
    ) var familiarWordStatss: FetchedResults<WordStats>
    
    @State var fontSize: CGFloat = 15
    
    var familiarWords: [String] {
        familiarWordStatss.map { $0.word! }
    }
    
    var familiarWordsSet: Set<String> {
        Set(familiarWords)
    }
    
    var words: [Word] {
        modelData.words
    }
    
    var foundWordsFromServices: [Word] {
        words.filter { ($0.translation != nil) && !familiarWordsSet.contains($0.text) && $0.isTranslationFromDictionaryServices  }
    }
    
    var notFoundWords: [Word] {
        words.filter { $0.translation == nil }
    }
    
    var body: some View {
        List {
            Slider(value: $fontSize, in: 0...50) {
                Text("Font Size")
            }

            Section(header: Text("Count = \(words.count)").foregroundColor(.primary)) {
                
            }
            
            Section(header: Text("Found:").foregroundColor(.secondary)) {
                ForEach(foundWordsFromServices, id: \.self) { word in
                    (Text(word.text).foregroundColor(.orange)
                        + Text(word.translation!).foregroundColor(.secondary))
                        .font(.system(size: fontSize))
                        .onTapGesture {
                            openDict(word.text)
                        }
//                        .frame(maxHeight: 60)
                }
            }

            Section(header: Text("NotFound:").foregroundColor(.secondary)) {
                ForEach(notFoundWords, id: \.self) { word in
                    Text(word.text)
                        .foregroundColor(.yellow)
//                        .frame(height: 20)
                }
            }
            
        }
    }
}

struct FamiliarWordsToggleViews: View {
    @State private var toggleFamiliarWordsView = false
    @State private var toggleUnFamiliarWordsView = false
    
    var body: some View {
        Toggle(isOn: $toggleUnFamiliarWordsView) {
            Text("See UnFamiliar Words")
        }
        if toggleUnFamiliarWordsView {
            UnFamiliarWordsView()
        }
        
        Toggle(isOn: $toggleFamiliarWordsView) {
            Text("See Familiar Words")
        }
        if toggleFamiliarWordsView {
            FamiliarWordsView()
        }
    }
}

let familiarThreshold = 50 // todo: make this value customiziable from UI

func openDict(_ word: String) {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    var arguments = [String]();
    arguments.append("dict://\(word)")
    task.arguments = arguments
    task.launch()
}

struct WordsView_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static var previews: some View {
        WordsView(modelData: modelData)
    }
}

