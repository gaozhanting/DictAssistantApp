//
//  NoisesView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import SwiftUI

struct NoisesView: View {
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
        let topViewController = NSHostingController(rootView: ConstantNoisesView())
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

private struct ConstantNoisesView: View {
    @FetchRequest(
        entity: Noise.entity(),
        sortDescriptors: []
    ) var fetchedNoises: FetchedResults<Noise>
    
    var text: String {
        fetchedNoises
            .map { $0.word! }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(text))
    }
}

private struct EditingView: View {
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
        batchInsertNoises(lines) {
            toastSucceed()
        }
    }
    
    func multiRemove() {
        removeMultiNoise(lines, didSucceed: {
            toastSucceed()
        }, nothingChanged: {
            toastNothingChanged()
        })
    }
    
    func batchDeleteAll() {
        batchDeleteAllNoise {
            toastSucceed()
        }
    }
    
    func batchResetDefault() {
        batchResetDefaultNoises() {
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
                    .disabled(lines.isContainsEmptyLine)
                    .help("Add multi noises")
                    
                    Button(action: multiRemove) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .disabled(lines.isContainsEmptyLine)
                    .help("Remove multi noises")
                    
                    Button(action: batchDeleteAll) {
                        Image(systemName: "trash")
                    }
                    .help("Delete All")
                    
                    Button(action: batchResetDefault) {
                        Image(systemName: "pencil.and.outline")
                    }
                    .help("Reset to Default")
                    
                    MiniInfoView {
                        InfoView()
                    }
                }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 20)
                    .padding(.bottom, 5)
                ,
                alignment: .bottomTrailing
            )
    }
}

private struct InfoView: View {
    var body: some View {
        Text("You can add custom noises here when you think the recognition word is non-exists. I make almost all one-letter and two-letter English words as default noises, because it always make noise when do text recognition in real time. You can add and remove(what I incorrect added) more noise. Noises are ignored when playing.")
            .infoStyle()
    }
}

struct NoiseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoisesView()
            InfoView()
        }
//                .environment(\.locale, .init(identifier: "zh-Hans"))
                .environment(\.locale, .init(identifier: "en"))
    }
}
