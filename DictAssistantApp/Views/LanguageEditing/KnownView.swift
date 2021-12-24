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

private struct SplitView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> some NSViewController {
        let controller = SplitViewController()
        return controller
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    }
}

private class SplitViewController: NSSplitViewController {
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
        splitView.setPosition(370, ofDividerAt: 0)
    }
}

private enum DisplayFilter: Int {
    case all = 0
    case words = 1
    case phrases = 2
}

private struct ConstantKnownView: View {
    @FetchRequest(
        entity: Known.entity(),
        sortDescriptors: []
    ) var fetchedKnown: FetchedResults<Known>

    @State private var selectedFlavor = DisplayFilter.all.rawValue
    
    func filter(_ word: String) -> Bool {
        switch DisplayFilter(rawValue: selectedFlavor)! {
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
                    Text("All").font(.callout).tag(DisplayFilter.all.rawValue)
                    Text("Words").font(.callout).tag(DisplayFilter.words.rawValue)
                    Text("Phrases").font(.callout).tag(DisplayFilter.phrases.rawValue)
                }
                .labelsHidden()
                .frame(maxWidth: 100)
                ,
                
                alignment: .bottomTrailing
            )
        
    }
}

private struct EditingView: View {
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
    
    @State private var showingAlert = false
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(
                GroupBox {
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
                        .disabled(isWordsInvalid)
                        .help("Add multi words to Known")
                        
                        Button(action: multiRemove) {
                            Image(systemName: "rectangle.stack.badge.minus")
                        }
                        .disabled(isWordsInvalid)
                        .help("Remove multi words from Known")
                        
                        Button(action: { showingAlert = true }) {
                            Image(systemName: "trash")
                        }
                        .help("Delete All")
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Delete All"),
                                message: Text("Are you sure? This action can't be undo. Recommend you save the text before, maybe save it in your Apple Notes."),
                                primaryButton: .default(
                                    Text("Cancel")
                                ),
                                secondaryButton: .destructive(
                                    Text("Delete"),
                                    action: batchDeleteAll
                                )
                            )
                        }
                        
                        PasteFirstNWikiWordFrequencyButton(text: $text)
                        PasteOxford3000Button(text: $text)
                        
                        MiniInfoView {
                            InfoPopoverView()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }, alignment: .bottomTrailing)
    }
}

private struct PasteOxford3000Button: View {
    @Binding var text: String
    
    var body: some View {
        Button(action: {
            let oxford3000Vocabulary = Vocabularies.readToArray(from: "oxford_3000.txt")
            text = oxford3000Vocabulary.joined(separator: "\n")
        }) {
            Image(systemName: "doc.on.clipboard")
                .overlay(
                    Image(systemName: "o.circle.fill")
                        .font(.system(size: 6, weight: .bold, design: .serif)),
                    alignment: .bottomLeading)
        }
        .help("Paste Oxford 3000 Vocabulary")
    }
}

private struct PasteFirstNWikiWordFrequencyButton: View {
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
        .popover(isPresented: $showPopover, arrowEdge: .top, content: {
            FirstNPopoverView(text: $text, showPopover: $showPopover)
        })
        .help("Paste first N from first 100_000 of Wiki English word frequency list")
    }
}

let minEnWikiCount = 1
let maxEnWikiCount = 100000
let defaultEnWikiCount = 5000
func validateEnWikiCountField(_ count: String) -> Bool {
    guard let count = Int(count) else {
        return false
    }
    
    if count < minEnWikiCount || count > maxEnWikiCount {
        return false
    }
    
    return true
}

private struct FirstNPopoverView: View {
    @Binding var text: String
    @Binding var showPopover: Bool
    
    @State var count: String = String(defaultEnWikiCount)
    @State var showingAlert: Bool = false
    
    func onCommit() {
        if !validateEnWikiCountField(count) {
            showingAlert = true
            return
        }
        
        let wikiFrequencyWords = Vocabularies.readToArray(from: "first_100_000_of_enwiki-20190320-words-frequency.txt")
        
        text = wikiFrequencyWords[0 ..< Int(count)!].joined(separator: "\n")
        showPopover = false
    }
    
    var body: some View {
        TextField("", text: $count, onCommit: onCommit)
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Invalid value"),
                    message: Text("Count must be an integer, and must between 1 and 100000, including.")
                )
            }
    }
}

private struct InfoPopoverView: View {
    var body: some View {
        Text("Edit your known English words, one word or one phrase per line; then add them to or remove them from your known words list.\n\nNotice: every line you edit must not be empty, and must not be only contains white space characters. So don't add a new empty line.")
            .infoStyle()
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
//                .environment(\.locale, .init(identifier: "en"))
        }
    }
}
