//
//  KnownWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import SwiftUI

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
        splitView.dividerStyle = .paneSplitter
        splitView.isVertical = false
        
        let topViewController = NSHostingController(rootView: FixedKnownWordsView())
        addSplitViewItem(
            NSSplitViewItem(
                viewController: topViewController))
        
        let bottomViewController = NSHostingController(rootView: EditingView())
        bottomViewController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        addSplitViewItem(
            NSSplitViewItem(
                viewController: bottomViewController))
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
        VStack {
            HStack {
                HStack {
                    HStack {
                        Button(action: { addMultiToKnownWords(Array(words)) }) {
                            Image(systemName: "rectangle.stack.badge.plus")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isWordsInvalid)
                        
                        Button(action: { removeMultiFromKnownWords(Array(words)) }) {
                            Image(systemName: "rectangle.stack.badge.minus")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isWordsInvalid)
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
                        
                        Button(action: { text = cet4Vocabulary }) {
                            Image(systemName: "doc.on.clipboard")
                                .overlay(
                                    Image(systemName: "c.circle.fill")
                                        .font(.system(size: 6, weight: .bold, design: .serif)),
                                    alignment: .bottomLeading)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { text = cet6Vocabulary }) {
                            Image(systemName: "doc.on.clipboard")
                                .overlay(
                                    Image(systemName: "d.circle.fill")
                                        .font(.system(size: 6, weight: .bold, design: .serif)),
                                    alignment: .bottomLeading)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.top, 5)
                
                Spacer()
            }
            
            TextEditor(text: $text)
        }
    }
}

func openDict(_ word: String) {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    var arguments = [String]();
    arguments.append("dict://\(word)")
    task.arguments = arguments
    task.launch()
}

struct KnownWordsView_Previews: PreviewProvider {
    static var previews: some View {
        KnownWordsView()
    }
}
