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
        splitView.setPosition(250, ofDividerAt: 0)
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
    
    // failed using NSApplication.shared.presentError(error as NSError)
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
        batchInsertCustomNoise(lines) {
            toastSucceed()
        }
    }
    
    func multiRemove() {
        removeMultiCustomNoise(lines, didSucceed: {
            toastSucceed()
        }, nothingChanged: {
            toastNothingChanged()
        })
    }
    
    func batchDeleteAll() {
        batchDeleteAllCustomNoise {
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

struct CustomNoiseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomNoiseView()
            InfoView()
        }
    }
}
