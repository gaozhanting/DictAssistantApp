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
        text.components(separatedBy: "\n")
    }
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(
                HStack {
                    Button(action: {
                        for line in lines {
                            let wordTrans = line.split(separator: Character(":"), maxSplits: 1)
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
                    }) {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled({
                        return lines.contains { line in
                            line.split(separator: Character(":"), maxSplits: 1)
                                .count < 2
                        }
                    }())
                    .help("Add multi entries to custom dict.")
                    
                    Button(action: {
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
                    }) {
                        Image(systemName: "rectangle.stack.badge.minus")
                    }
                    .disabled({
                        lines.count <= 0
                    }())
                    .buttonStyle(PlainButtonStyle())
                    .help("Add multi entries to custom dict.")
                    
                    MiniInfoView {
                        InfoPopoverView()
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 5)
                ,
                alignment: .bottomTrailing
            )
    }
}

fileprivate struct InfoPopoverView: View {
    var body: some View {
        Text("Info")
            .padding()
    }
}

struct CustomDictView_Previews: PreviewProvider {
    static var previews: some View {
        CustomDictView()
    }
}
