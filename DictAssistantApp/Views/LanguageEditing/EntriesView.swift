//
//  EntriesView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/24.
//

import SwiftUI

struct EntryView: View {
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
        let topViewController = NSHostingController(rootView: ConstantEntryView())
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

fileprivate struct ConstantEntryView: View {
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: []
    ) var fetchedEntry: FetchedResults<Entry>
    
    var text: String {
        fetchedEntry
            .map { entry in "\(entry.word!),\(entry.trans!)" }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(text))
    }
}

fileprivate struct EditingView: View {
    @State private var text = ""
    
    var lines: [String] {
        text.components(separatedBy: .newlines)
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
    
    func batchUpsert() {
        let entries: [(String, String)] = lines.map { line in
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            return (String(wordTrans[0]), String(wordTrans[1]))
        }
        batchUpsertEntries(entries: entries) {
            toastSucceed()
        }
    }
    
    func multiRemove() {
        removeMultiEntries(lines, didSucceed: {
            toastSucceed()
        }, nothingChanged: {
            toastNothingChanged()
        })
    }
    
    func batchDeleteAll() {
        batchDeleteAllEntries {
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
                    
                    Button(action: batchUpsert) {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled({
                        lines.contains { line in
                            line.split(separator: Character(","), maxSplits: 1)
                                .count < 2
                        }
                    }())
                    .help("Add multi entries to custom dict")
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .disabled(lines.isContainsEmptyLine)
                    .buttonStyle(PlainButtonStyle())
                    .help("Remove multi entries to custom dict")
                    
                    Button(action: { showingAlert = true }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete All")
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Delete All"),
                            message: Text("Are you sure? This action can't be undo. Recommend you save the text before, maybe save it in your Apple Notes."),
                            primaryButton: .default(
                                Text("Cancel"),
                                action: { print("Cancelled") }
                            ),
                            secondaryButton: .destructive(
                                Text("Delete"),
                                action: batchDeleteAll
                            )
                        )
                    }
                    
                    MiniInfoView {
                        InfoView()
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 5)
                ,
                alignment: .bottomTrailing
            )
    }
    
    @State private var showingAlert = false
}

private struct InfoView: View {
    var body: some View {
        Text("Edit your custom dictionary entries, one entry per line. \n\nThe line format for adding is:\nword,translation \n\nThe line format for removing is:\nword \n\nThen add them to or remove them from your custom dict.\n\nNotice: every line you edit must not be empty, and must not be only contains white space characters. So don't add a new empty line.")
            .padding()
            .frame(width: 300, height: 300)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EntryView()
            
            InfoView()
        }
    }
}
