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
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
    @Environment(\.colorScheme) var colorScheme

    let wordCell: WordCell

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
    
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.highlightColor)!
    var theWordColor: Color {
        Color(dataToColor(wordColor)!)
    }
    var theKnownWordColor: Color {
        theWordColor.opacity(0.5)
    }
    var theTransColor: Color {
        Color(dataToColor(transColor)!)
    }
    
    @AppStorage(FontKey) private var fontData: Data = fontToData(NSFont.systemFont(ofSize: CGFloat(0.0)))!
    var font: Font {
        Font(dataToFont(fontData)!)
    }

    // title title2 : landscape
    // headline callout : portrait
    
    var textView: some View {
        unKnown ?
            Text(word)
            .foregroundColor(theWordColor)
            .font(font) +
            Text(transText)
            .foregroundColor(theTransColor)
            .font(font) :
            
            Text(word)
            .foregroundColor(theKnownWordColor)
            .font(font)
    }
    
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!
    var theBackgroundColor: Color {
        Color(dataToColor(backgroundColor)!)
    }
    
    @AppStorage(ContentBackgroundDisplayKey) private var contentBackgroundDisplay: Bool = false
    
    var TextBody: some View {
        textView
            .opacity( (known && isPhrase) ? 0.5 : 1)
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
            .background(contentBackgroundDisplay ? nil : theBackgroundColor)
    }

    var body: some View {
        switch contentStyle {
        case .portrait:
            TextBody

        case .landscape:
            VStack {
                TextBody
                Spacer()
            }
        }
    }
}

//struct SingleWordView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleWordView()
//    }
//}
