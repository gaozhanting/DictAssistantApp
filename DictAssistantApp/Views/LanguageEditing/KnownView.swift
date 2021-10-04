//
//  KnownView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import SwiftUI
import DataBases

struct KnownView: View {
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
        let topViewController = NSHostingController(rootView: ConstantKnownView())
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
        splitView.setPosition(250, ofDividerAt: 0)
    }
}

fileprivate enum DisplayFilter: String, CaseIterable, Identifiable {
    case all
    case words
    case phrases

    var id: String { self.rawValue }
}

fileprivate struct ConstantKnownView: View {
    @FetchRequest(
        entity: Known.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Known.word, ascending: true)
        ]
    ) var fetchedKnown: FetchedResults<Known>

    @State private var selectedFlavor = DisplayFilter.all
    
    func filter(_ word: String) -> Bool {
        switch selectedFlavor {
        case .all:
            return true
        case .words:
            return !word.isPhrase
        case .phrases:
            return word.isPhrase
        }
    }
    
    var flavorKnown: String {
        fetchedKnown
            .map { $0.word! }
            .filter { filter($0) }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(flavorKnown))
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
        text.components(separatedBy: .newlines)
            .map{ String($0) }
    }
    
    var isWordsInvalid: Bool {
        if text.isEmpty {
            return true
        }
        
        // if one line (as a word) all spaces or empty, invalid the text, thus can't add or remove
        for word in words {
            if word.isEmpty {
                return true
            }
            
            if word.allSatisfy({ $0.isWhitespace }) {
                return true
            }
        }
        
        return false
    }
    
    func toastSucceed(callBack: @escaping () -> Void = {}) {
        withAnimation {
            succeed = true
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
                succeed = false
                callBack()
            }
        }
    }
    
    func toastNothingChanged() {
        withAnimation {
            nothingChanged = true
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
                nothingChanged = false
            }
        }
    }
    
    func batchInsert() {
        batchInsertKnown(words) {
            toastSucceed()
        }
    }
    
    func multiRemove() {
        removeMultiKnown(words, didSucceed: {
            toastSucceed()
        }, nothingChanged: {
            toastNothingChanged()
        })
    }
    
    func batchDeleteAll() {
        batchDeleteAllKnown {
            toastSucceed()
        }
    }
    
    @State private var succeed: Bool = false
    @State private var nothingChanged: Bool = false
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(
                HStack {
                    if succeed {
                        Text("Succeed")
                            .transition(.move(edge: .bottom))
                    }
                    if nothingChanged {
                        Text("Nothing Changed")
                            .transition(.move(edge: .bottom))
                    }
                    
                    Button(action: batchInsert) {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isWordsInvalid)
                    .help("Add multi words to Known")
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isWordsInvalid)
                    .help("Remove multi words from Known")
                    
                    Button(action: batchDeleteAll) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    PasteFirstNWikiWordFrequencyButton(text: $text)
                    PasteOxford3000Button(text: $text)
                    
                    MiniInfoView {
                        InfoPopoverView()
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 5)
                ,
                alignment: .bottomTrailing
            )
    }
}

fileprivate struct PasteOxford3000Button: View {
    @Binding var text: String
    
    var body: some View {
        Button(action: { text = oxford3000Words.joined(separator: "\n") }) {
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

fileprivate var oxford3000Words: [String] {
    var words = oxford3000Vocabulary.components(separatedBy: .newlines).map{ String($0) }
    words.removeLast()
    return words
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

let wikiFrequencyWords: [String] = wikiFrequencyWordsList.components(separatedBy: .newlines).map{ String($0) }

fileprivate struct FirstNPopoverView: View {
    @Binding var text: String
    
    @State private var from: Int = 1
    @State private var to: Int = 5000
    @State private var committed: Bool = false
    
    @Binding var showPopover: Bool
    
    var body: some View {
        HStack {
            Text("from")
            TextField("", value: $from, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 1
                formatter.maximum = 100000
                return formatter
            }())
            .frame(width: 60)
            
            Text("to")
            TextField("", value: $to, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 2
                formatter.maximum = 100000
                return formatter
            }(), onCommit: {
                committed = true
            })
            .frame(width: 60)
            
            Button(action: {
                text = wikiFrequencyWords[from-1 ..< to].joined(separator: "\n")
                showPopover = false
            }) {
                Image(systemName: "doc.on.clipboard")
            }
            .disabled(from > to || !committed)
            .keyboardShortcut(KeyEquivalent.return) // command + return
            .help("Type a range, then press paste button to paste these words below.")
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

fileprivate struct InfoPopoverView: View {
    var body: some View {
        Text("Edit your known English words, one word or one phrase per line; then add them to or remove them from your known words list.\n\nNotice: every line you edit must not be empty, and must not be only contains white space characters. So don't add a new empty line.")
            .padding()
            .frame(width: 300, height: 160)
    }
}

struct KnownView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KnownView()
                .frame(width: 300, height: 600)
            
            FirstNPopoverView(text: Binding.constant(""), showPopover: Binding.constant(false))
            
            InfoPopoverView()
                .environment(\.locale, .init(identifier: "zh-Hant"))
        }
    }
}