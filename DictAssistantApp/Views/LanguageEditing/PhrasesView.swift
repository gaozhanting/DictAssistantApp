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
        splitView.setPosition(250, ofDividerAt: 0)
    }
}

fileprivate struct ConstantPhrasesView: View {
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
                    
                    Button(action: batchDeleteAll) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete All")
                    
                    Button(action: batchResetDefault) {
                        Image(systemName: "pencil.and.outline")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Reset to Default")
                    
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
        Text("The phrases here aim as a database for the app to detect phrases. The dataset is extracted from Oxford Concise Dict and enwiki words frequency list (hyphen phrases). You can add more phrases here. You can reset, to use this default dataset. You can deselect show phrases option to ignore it. When you add your custom dict entry, if the word is a phrase, it will be automatically added here.")
            .padding()
            .frame(width: 400, height: 150)
    }
}

struct PhrasesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PhrasesView()
            InfoView()
        }
    }
}
