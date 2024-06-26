//
//  EntriesView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/24.
//

import SwiftUI

struct EntriesView: View {
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
        splitView.setPosition(370, ofDividerAt: 0)
    }
}

private struct ConstantEntryView: View {
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

private struct EditingView: View {
    @State var text = ""
    
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
    
    @State var succeed: Bool = false
    @State var nothingChanged: Bool = false
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
            
            HStack {
                Spacer()
                
                if succeed {
                    Text("Succeed")
                        .transition(.move(edge: .bottom))
                }
                if nothingChanged {
                    Text("Nothing changed")
                        .transition(.move(edge: .bottom))
                }
                
                Button(action: batchUpsert) {
                    Image(systemName: "rectangle.stack.badge.plus")
                }
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
                .help("Remove multi entries to custom dict")
                
                Button(action: { showingAlert = true }) {
                    Image(systemName: "trash")
                }
                .help("Delete all")
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Delete all"),
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
                
                MiniInfoView {
                    InfoView()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @State var showingAlert = false
}

private struct InfoView: View {
    var body: some View {
        Text("Edit your custom dictionary entries, one entry per line. \n\nThe line format for adding is:\nword,translation \n\nThe line format for removing is:\nword \n\nThen add them to or remove them from your custom dict.\n\nNotice: every line you edit must not be empty, and must not be only contains white space characters. So don't add a new empty line.\n\nNote: The custom entries here aims to make a flexible custom dict in the app which you can play with, not aims to be a standard dictionary. Although it still works, the editor here will becomes stuck with huge text, sorry.")
            .infoStyle()
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EntriesView()
                .frame(width: 300, height: 600)
            
            InfoView()
        }
    }
}
