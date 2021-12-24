//
//  PhrasesView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import SwiftUI

struct PhrasesView: View {
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
        let topViewController = NSHostingController(rootView: ConstantPhrasesView())
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

private struct ConstantPhrasesView: View {
    @FetchRequest(
        entity: Phrase.entity(),
        sortDescriptors: []
    ) var fetchedPhrases: FetchedResults<Phrase>
    
    var text: String {
        fetchedPhrases
            .map { $0.word! }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(text))
    }
}

extension Array where Element == String {
    var isContainsEmptyLine: Bool {
        self.contains { line in
            line.allSatisfy { c in
                c.isWhitespace
            }
        }
    }
}

private struct EditingView: View {
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
    
    func batchInsert() {
        batchInsertPhrases(lines) {
            toastSucceed()
        }
    }
    
    func multiRemove() {
        removeMultiPhrases(lines, didSucceed: {
            toastSucceed()
        }, nothingChanged: {
            toastNothingChanged()
        })
    }
    
    func batchDeleteAll() {
        batchDeleteAllPhrases {
            toastSucceed()
        }
    }
    
    func batchResetDefault() {
        batchResetDefaultPhrases {
            toastSucceed()
        }
    }
    
    @State private var succeed: Bool = false
    @State private var nothingChanged: Bool = false
    
    @State private var showingDeleteAllAlert: Bool = false
    @State private var showingResetAlert: Bool = false
    
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
                    .disabled(lines.isContainsEmptyLine)
                    .help("Add multi phrases")
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(lines.isContainsEmptyLine)
                    .help("Remove multi phrases")
                    
                    Button(action: { showingDeleteAllAlert = true }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete All")
                    .alert(isPresented: $showingDeleteAllAlert) {
                        Alert(
                            title: Text("Delete All"),
                            message: Text("Are you sure? This action can't be undo."),
                            primaryButton: .default(
                                Text("Cancel")
                            ),
                            secondaryButton: .destructive(
                                Text("Delete"),
                                action: batchDeleteAll
                            )
                        )
                    }
                    
                    Button(action: { showingResetAlert = true }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Reset to Default")
                    .alert(isPresented: $showingResetAlert) {
                        Alert(
                            title: Text("Reset"),
                            message: Text("Are you sure? This action can't be undo."),
                            primaryButton: .default(
                                Text("Cancel")
                            ),
                            secondaryButton: .destructive(
                                Text("Reset"),
                                action: batchResetDefault
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
}

private struct InfoView: View {
    var body: some View {
        Text("The phrases here aim as a database for the app to detect phrases. The App can only detect continuous phrases. The dataset is extracted from Oxford Concise Dict and enwiki words frequency list (hyphen phrases). You can add more phrases here. You can reset, to use this default dataset. You can deselect show phrases option to ignore it. When you add your custom dict entry, if the word is a phrase, it will be automatically added here.")
            .infoStyle()
    }
}

struct PhrasesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PhrasesView()
            InfoView()
        }
//                .environment(\.locale, .init(identifier: "zh-Hans"))
                .environment(\.locale, .init(identifier: "en"))
    }
}
