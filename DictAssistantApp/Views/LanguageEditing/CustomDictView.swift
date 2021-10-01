//
//  CustomDictView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/24.
//

import SwiftUI

struct CustomDictView: View {
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
        let topViewController = NSHostingController(rootView: FixedCustomDictView())
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

fileprivate struct FixedCustomDictView: View {
    @FetchRequest(
        entity: CustomDict.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CustomDict.word, ascending: true)
        ]
    ) var fetchedCustomDict: FetchedResults<CustomDict>
    
    var text: String {
        fetchedCustomDict
            .map { entry in "\(entry.word!),\(entry.trans!)" }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(text))
    }
}

struct Entry: Hashable {
    let word: String
    let trans: String
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
    
    func multiAdd() {
        let entries: [Entry] = lines.map { line in
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            return Entry(word: String(wordTrans[0]), trans: String(wordTrans[1]))
        }
        batchUpsertCustomDicts(entries: entries) {
            toastSucceed {
                showCustomDictPanelX()
            }
        }
    }
    
    func multiRemove() {
        removeMultiCustomDict(lines, didSucceed: {
            toastSucceed() {
                showCustomDictPanelX()
            }
        }, nothingChanged: {
            toastNothingChanged()
        })
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
                    
                    Button(action: multiAdd) {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled({
                        lines.contains { line in
                            line.split(separator: Character(","), maxSplits: 1)
                                .count < 2
                        }
                    }())
                    .help("Add multi entries to custom dict.")
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .disabled(lines.isContainsEmptyLine)
                    .buttonStyle(PlainButtonStyle())
                    .help("Remove multi entries to custom dict.")
                    
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
        Text("Edit your custom dictionary entries, one entry per line. \n\nThe line format for adding is:\nword,translation \n\nThe line format for removing is:\nword \n\nThen add them to or remove them from your custom dict.\n\nNotice: every line you edit must not be empty, and must not be only contains white space characters. So don't add a new empty line.")
            .padding()
            .frame(width: 300, height: 300)
    }
}

struct CustomDictView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomDictView()
            
            InfoView()
        }
    }
}
