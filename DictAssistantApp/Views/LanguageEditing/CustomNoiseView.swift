//
//  CustomNoiseView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import SwiftUI

struct CustomNoiseView: View {
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
        let topViewController = NSHostingController(rootView: FixedCustomNoisesView())
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

fileprivate struct FixedCustomNoisesView: View {
    @FetchRequest(
        entity: CustomNoise.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CustomNoise.word, ascending: true)
        ]
    ) var fetchedCustomNoises: FetchedResults<CustomNoise>
    
    var text: String {
        fetchedCustomNoises
            .map { $0.word! }
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
    
    func multiAdd() {
        batchInsertCustomNoise(lines)
    }
    
    func multiRemove() {
        removeMultiCustomNoise(lines)
    }
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(
                HStack {
                    Button(action: multiAdd) {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isContainEmptyLine(lines))
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isContainEmptyLine(lines))
                    
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

struct CustomNoiseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomNoiseView()
            InfoView()
        }
    }
}
