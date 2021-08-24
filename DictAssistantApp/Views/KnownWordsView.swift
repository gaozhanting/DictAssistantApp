//
//  KnownWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import SwiftUI
import DataBases

struct KnownWordsView: View {
    var body: some View {
        SplitView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

fileprivate struct SplitView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> some NSViewController {
        let controller = SplitViewController()
        return controller
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    }
}

fileprivate class SplitViewController: NSSplitViewController {
    override func viewDidLoad() {
        let topViewController = NSHostingController(rootView: FixedKnownWordsView())
        addSplitViewItem(
            NSSplitViewItem(
                viewController: topViewController))
        
        let bottomViewController = NSHostingController(rootView: EditingView())
        bottomViewController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        addSplitViewItem(
            NSSplitViewItem(
                viewController: bottomViewController))
        
        splitView.dividerStyle = .paneSplitter
        splitView.isVertical = false
        splitView.setPosition(320, ofDividerAt: 0)
    }
}

fileprivate enum DisplayFilter: String, CaseIterable, Identifiable {
    case all
    case words
    case phrases

    var id: String { self.rawValue }
}

fileprivate struct FixedKnownWordsView: View {
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.word, ascending: true)
        ]
    ) var fetchedKnownWords: FetchedResults<WordStats>

    @State private var selectedFlavor = DisplayFilter.all
    
    func filter(_ word: String) -> Bool {
        switch selectedFlavor {
        case .all:
            return true
        case .words:
            return !isAPhrase(word)
        case .phrases:
            return isAPhrase(word)
        }
    }
    
    var flavorKnownWords: String {
        fetchedKnownWords
            .map { $0.word! }
            .filter { filter($0) }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(flavorKnownWords))
            .overlay(
                Picker("", selection: $selectedFlavor) {
                    Text("All").tag(DisplayFilter.all)
                    Text("Words").tag(DisplayFilter.words)
                    Text("Phrases").tag(DisplayFilter.phrases)
                }
                .labelsHidden()
                .frame(maxWidth: 100)
                ,
                
                alignment: .bottomTrailing
            )
        
    }
}

fileprivate struct EditingView: View {
    @State private var text = ""
    
    var words: [String] {
        text.split(separator: "\n")
            .map{ String($0) }
    }
        
    var isWordsInvalid: Bool {
        if text.isEmpty {
            return true
        }
        
//        for word in words {
//            for char in word {
//                if !validEnglishWordsCharacterSet.contains(char) {
//                    return true
//                }
//            }
//        }
        
        return false
    }
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(
                VStack {
                    AddMultiButton(words: words, isWordsInvalid: isWordsInvalid)
                    RemoveMultiButton(words: words, isWordsInvalid: isWordsInvalid)
                    
                    PasteFirstNWikiWordFrequencyButton(text: $text)
                    PasteOxford3000Button(text: $text)
                    
                    ShowInfoIcon()
                }
                ,
                alignment: .trailing
            )
    }
}

fileprivate struct AddMultiButton: View {
    @Environment(\.addMultiToKnownWords) var addMultiToKnownWords
    
    let words: [String]
    let isWordsInvalid: Bool

    var body: some View {
        Button(action: { addMultiToKnownWords(Array(words)) }) {
            Image(systemName: "rectangle.stack.badge.plus")
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isWordsInvalid)
        .help("Add multi words to Known")
    }
}

fileprivate struct RemoveMultiButton: View {
    @Environment(\.removeMultiFromKnownWords) var removeMultiFromKnownWords

    let words: [String]
    let isWordsInvalid: Bool

    var body: some View {
        Button(action: { removeMultiFromKnownWords(Array(words)) }) {
            Image(systemName: "rectangle.stack.badge.minus")
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isWordsInvalid)
        .help("Remove multi words from Known")
    }
}

fileprivate struct PasteOxford3000Button: View {
    @Binding var text: String
    
    var body: some View {
        Button(action: { text = oxford3000Vocabulary }) {
            Image(systemName: "doc.on.clipboard")
                .overlay(
                    Image(systemName: "o.circle.fill")
                        .font(.system(size: 6, weight: .bold, design: .serif)),
                    alignment: .bottomLeading)
        }
        .buttonStyle(PlainButtonStyle())
        .help("Paste Oxford 3000 Vocabulary")
    }
}

fileprivate struct PasteFirstNWikiWordFrequencyButton: View {
    @Binding var text: String
    
    @State private var showPopover = false
    
    var body: some View {
        Button(action: { showPopover = true }) {
            Image(systemName: "doc.on.clipboard")
                .overlay(
                    Image(systemName: "w.circle.fill")
                        .font(.system(size: 6, weight: .bold, design: .serif)),
                    alignment: .bottomLeading)
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showPopover, arrowEdge: .bottom, content: {
            FirstNPopoverView(text: $text, showPopover: $showPopover)
        })
        .help("Paste first N from first 100_000 of Wiki English word frequency list")
    }
}

fileprivate let wikiFrequencyWords: [String] = wikiFrequencyWordsList.split(separator: "\n").map{ String($0) }

fileprivate struct FirstNPopoverView: View {
    @Binding var text: String
    
    @State private var from = 1.0
    @State private var to = 5000.0
    
    @Binding var showPopover: Bool
    
    var body: some View {
        HStack {
            Text("from")
            TextField("", value: $from, formatter: formatter)
                .frame(width: 60)
            
            Text("to")
            TextField("", value: $to, formatter: formatter)
                .frame(width: 60)
            
            Button(action: {
                text = wikiFrequencyWords[Int(from) ..< Int(to)].joined(separator: "\n")
                showPopover = false
            }) {
                Image(systemName: "doc.on.clipboard")
            }
            .help("Type a range, then press paste button to paste these words below.")
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

fileprivate struct ShowInfoIcon: View {
    @State private var showInfo = false

    var body: some View {
        Button(action: { showInfo = true }) {
            Image(systemName: "info.circle")
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showInfo, arrowEdge: .top, content: {
            InfoPopoverView()
        })
//        .padding(.horizontal, 10)
    }
}

fileprivate struct InfoPopoverView: View {
    var body: some View {
        Text("Edit your known English words, one word a line; then add or remove them to or from your known words list.")
            .padding()
            .frame(width: 300, height: 80)
    }
}

struct KnownWordsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KnownWordsView()
                .frame(width: 300, height: 600)
            
            FirstNPopoverView(text: Binding.constant(""), showPopover: Binding.constant(false))
            
            InfoPopoverView()
        }
    }
}
