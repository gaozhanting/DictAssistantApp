//
//  SingleWordView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/24.
//

import SwiftUI

struct SingleWordView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.addToKnownWords) var addToKnownWords
    @Environment(\.removeFromKnownWords) var removeFromKnownWords
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(FontRateKey) private var fontRate: Double = 0.6
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portraitNormal

    let wordCell: WordCell
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat

    var isKnown: IsKnown {
        wordCell.isKnown
    }
    
    var unKnown: Bool {
        isKnown == .unKnown
    }
    
    var known: Bool {
        isKnown == .known
    }
    
    var word: String {
        wordCell.word
    }
    
    var isPhrase: Bool {
        word.contains(" ")
    }
    
    var trans: String {
        wordCell.trans
    }
    
    var transText: String {
        isAddLineBreak ? "\n" + trans : trans
    }

    func openExternalDict(_ word: String) {
        let replaceSpaced = word.replacingOccurrences(of: " ", with: "-")
        guard let url = URL(string: "https://www.collinsdictionary.com/dictionary/english/\(replaceSpaced)") else {
            logger.info("invalid external dict url string")
            return
        }
        openURL(url)
    }
    
    var textView: some View {
        unKnown ?
            (Text(word).foregroundColor(Color(color)).font(Font.custom(fontName, size: fontSize)) + Text(transText).foregroundColor(.white).font(Font.custom(fontName, size: fontSize * CGFloat(fontRate))))
            :
            Text(word).foregroundColor(.gray)
    }
    
    var body: some View {
        VStack {
            textView
                .opacity( (known && isPhrase) ? 0.5 : 1)
                .font(Font.custom(fontName, size: fontSize))
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .contextMenu {
                    Button(unKnown ? "Add to Known" : "Remove from known", action: {
                        unKnown ? addToKnownWords(word) : removeFromKnownWords(word)
                    })
                    Menu("Online Dict Link") {
                        Button("Collins", action: { openExternalDict(word) })
                    }
                }
                .onTapGesture(count: 2) {
                    openDict(word)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(Color.black.opacity(contentStyle == .landscapeMini ? 0.75 : 0))
            
            Spacer()
        }
    }
}

//struct SingleWordView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleWordView()
//    }
//}
