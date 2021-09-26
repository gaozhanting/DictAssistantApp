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
            .map { entry in "\(entry.word!): \(entry.trans!)" }
            .joined(separator: "\n")
    }
    
    var body: some View {
        TextEditor(text: Binding.constant(text))
    }
}

fileprivate struct EditingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @State private var text = ""
    var lines: [String] {
        text.components(separatedBy: .newlines)
    }
    
    func multiAdd() {
        for line in lines {
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            let word = String(wordTrans[0])
            let trans = String(wordTrans[1])
            
            let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word = %@", word)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try managedObjectContext.fetch(fetchRequest)
                if let result = results.first {
                    managedObjectContext.delete(result)
                }
                let entry = CustomDict(context: managedObjectContext)
                entry.word = word
                entry.trans = trans
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        save()
    }
    
    func multiRemove() {
        for line in lines {
            let word = line
            
            let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word = %@", word)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try managedObjectContext.fetch(fetchRequest)
                if let result = results.first {
                    managedObjectContext.delete(result)
                }
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        save()
    }
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(
                HStack {
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
                    .disabled({
                        lines.contains { line in
                            line.allSatisfy { c in
                                c.isWhitespace
                            }
                        }
                    }())
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
