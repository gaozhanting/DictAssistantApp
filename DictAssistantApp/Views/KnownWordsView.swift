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

struct SplitView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> some NSViewController {
        let controller = SplitViewController()
        return controller
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    }
}

class SplitViewController: NSSplitViewController {
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

struct FixedKnownWordsView: View {
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.word, ascending: true)
        ]
    ) var fetchedKnownWords: FetchedResults<WordStats>
    
    var knownWords: String {
        fetchedKnownWords
            .map { $0.word! }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(knownWords))
    }
}

struct EditingView: View {
    @Environment(\.removeMultiFromKnownWords) var removeMultiFromKnownWords
    @Environment(\.addMultiToKnownWords) var addMultiToKnownWords

    @State private var text = ""
    
    @State private var showInfo = false
    
    var words: [String] {
        text.split(separator: "\n")
            .map{ String($0) }
    }
        
    var isWordsInvalid: Bool {
        if text.isEmpty {
            return true
        }
        
        for word in words {
            for char in word {
                if !TextProcess.validEnglishWordsCharacterSet.contains(char) {
                    return true
                }
            }
        }
        
        return false
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    HStack {
                        Button(action: { addMultiToKnownWords(Array(words)) }) {
                            Image(systemName: "rectangle.stack.badge.plus")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isWordsInvalid)
                        .help("Add multi words to Known")
                        
                        Button(action: { removeMultiFromKnownWords(Array(words)) }) {
                            Image(systemName: "rectangle.stack.badge.minus")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isWordsInvalid)
                        .help("Remove multi words from Known")
                    }
                    .padding(.horizontal, 10)
                    
                    HStack {
                        Button(action: { text = highSchoolVocabulary }) {
                            Image(systemName: "doc.on.clipboard")
                                .overlay(
                                    Image(systemName: "h.circle.fill")
                                        .font(.system(size: 6, weight: .bold, design: .serif)),
                                    alignment: .bottomLeading)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Paste HighSchool Vocabulary")
                        
                        Button(action: { text = oxford3000Vocabulary }) {
                            Image(systemName: "doc.on.clipboard")
                                .overlay(
                                    Image(systemName: "o.circle.fill")
                                        .font(.system(size: 6, weight: .bold, design: .serif)),
                                    alignment: .bottomLeading)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Paste Oxford 3000 Vocabulary")
                        
                        Button(action: { text = cet4Vocabulary }) {
                            Image(systemName: "doc.on.clipboard")
                                .overlay(
                                    Image(systemName: "c.circle.fill")
                                        .font(.system(size: 6, weight: .bold, design: .serif)),
                                    alignment: .bottomLeading)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Paste CET4 Vocabulary")
                        
                        Button(action: { text = cet6Vocabulary }) {
                            Image(systemName: "doc.on.clipboard")
                                .overlay(
                                    Image(systemName: "d.circle.fill")
                                        .font(.system(size: 6, weight: .bold, design: .serif)),
                                    alignment: .bottomLeading)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Paste CET6 Vocabulary")
                    }
                    .padding(.horizontal, 10)
                    
                    Button(action: {
                        withAnimation {
                            showInfo.toggle()
                        }
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Show Info")
                    .padding(.horizontal, 10)
                }
                .padding(.top, 5)
                
                Spacer()
            }
            
            if showInfo {
                Divider()
                (Text("Edit one word every line; valid character of a word should only be ") + Text("a-z A-Z - ' . or space").foregroundColor(.green))
                    .padding(.leading, 4)
            }
            
            TextEditor(text: $text)
        }
    }
}

struct KnownWordsView_Previews: PreviewProvider {
    static var previews: some View {
        KnownWordsView()
    }
}
