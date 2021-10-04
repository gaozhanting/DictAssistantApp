//
//  CustomPhrasesView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import SwiftUI

struct CustomPhrasesView: View {
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
        let topViewController = NSHostingController(rootView: FixedCustomPhrasesView())
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

fileprivate struct FixedCustomPhrasesView: View {
    @FetchRequest(
        entity: CustomPhrase.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CustomPhrase.phrase, ascending: true)
        ]
    ) var fetchedCustomPhrases: FetchedResults<CustomPhrase>
    
    var text: String {
        fetchedCustomPhrases
            .map { $0.phrase! }
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
        batchInsertCustomPhrases(lines) {
            toastSucceed()
        }
    }
    
    func multiRemove() {
        removeMultiCustomPhrases(lines, didSucceed: {
            toastSucceed()
        }, nothingChanged: {
            toastNothingChanged()
        })
    }
    
    func batchDeleteAll() {
        batchDeleteAllCustomPhrases {
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
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(lines.isContainsEmptyLine)
                    
                    Button(action: batchDeleteAll) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
        Text("Info")
            .padding()
    }
}

struct CustomPhrasesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomPhrasesView()
            InfoView()
        }
    }
}
