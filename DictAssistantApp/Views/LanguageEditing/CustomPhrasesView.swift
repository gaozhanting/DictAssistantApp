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
        splitView.setPosition(320, ofDividerAt: 0)
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

fileprivate struct EditingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.addMultiCustomPhrases) var addMultiCustomPhrases
    @Environment(\.removeMultiCustomPhrases) var removeMultiCustomPhrases
    
    @State private var text = ""
    var lines: [String] {
        text.components(separatedBy: .newlines)
    }
    
    func multiAdd() {
        addMultiCustomPhrases(lines)
    }
    
    func multiRemove() {
        removeMultiCustomPhrases(lines)
    }
    
    func isContainEmptyLine() -> Bool {
        lines.contains { line in
            line.allSatisfy { c in
                c.isWhitespace
            }
        }
    }
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(
                HStack {
                    Button(action: multiAdd) {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isContainEmptyLine())
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isContainEmptyLine())
                    
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
