//
//  SingleWordView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/24.
//

import SwiftUI

struct SingleWordView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait

    let wordCell: WordCell

    var body: some View {
        switch contentStyle {
        case .portrait:
            TextBody(wordCell: wordCell)

        case .landscape:
            VStack {
                TextBody(wordCell: wordCell)
                Spacer()
            }
        }
    }
}

fileprivate struct TextBody: View {
    let wordCell: WordCell
    
    var word: String {
        wordCell.word
    }
    
    var isPhrase: Bool {
        isAPhrase(word)
    }
    
    var known: Bool {
        wordCell.isKnown == .known
    }
    
    var unKnown: Bool {
        wordCell.isKnown == .unKnown
    }
    
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!
    var theBackgroundColor: Color {
        Color(dataToColor(backgroundColor)!)
    }
    
    @Environment(\.addToKnownWords) var addToKnownWords
    @Environment(\.removeFromKnownWords) var removeFromKnownWords

    @Environment(\.openURL) var openURL
    func openExternalDict(_ word: String, urlPrefix: String) {
        let replaceSpaced = word.replacingOccurrences(of: " ", with: "-")
        guard let url = URL(string: "\(urlPrefix)\(replaceSpaced)") else {
            logger.info("invalid external dict url string")
            return
        }
        openURL(url)
    }
    
    func openCollins(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.collinsdictionary.com/dictionary/english/")
    }
    
    func openCambridge(_ word: String) {
        openExternalDict(word, urlPrefix: "https://dictionary.cambridge.org/dictionary/english/")
    }
    
    func openMacMillian(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.macmillandictionary.com/dictionary/british/") // not work for phrase
    }
    
    func openLexico(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.lexico.com/en/definition/")
    }
    
    func openDictionary(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.dictionary.com/browse/")
    }
    
    func openThesaurus(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.thesaurus.com/browse/")
    }

    @AppStorage(SpeakWordToggleKey) private var speakWordToggle: Bool = false

    var body: some View {
        TextWithShadow(wordCell: wordCell)
            .opacity( (known && isPhrase) ? 0.5 : 1)
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .contextMenu {
                Button(unKnown ? "Add to Known" : "Remove from known", action: {
                    unKnown ? addToKnownWords(word) : removeFromKnownWords(word)
                })
                Menu("Online Dict Link") {
                    Button("Collins", action: { openCollins(word) })
                    Button("Cambridge", action: { openCambridge(word) })
//                    Button("MacMillian", action: { openMacMillian(word) })
                    Button("Lexico", action: { openLexico(word) })
                    Button("Dictionary", action: { openDictionary(word) })
                    Button("Thesaurus", action: { openThesaurus(word) })
                }
            }
            .onTapGesture(count: 2) {
                openDict(word)
            }
            .onLongPressGesture {
                if speakWordToggle {
                    say(word)
                }
            }
            .background(!contentBackgroundVisualEffect && contentStyle == .landscape ? theBackgroundColor : nil)
    }
    
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
}

fileprivate struct TextWithShadow: View {
    @AppStorage(ShadowColorKey) private var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) private var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) private var shadowXOffset: Double = 0
    @AppStorage(ShadowYOffSetKey) private var shadowYOffset: Double = 2

    @AppStorage(TextShadowToggleKey) private var textShadowToggle: Bool = false
    
    let wordCell: WordCell
    
    var body: some View {
        if textShadowToggle {
            TheText(wordCell: wordCell)
                .shadow(
                    color: Color(dataToColor(shadowColor)!), // Color(NSColor.labelColor.withAlphaComponent(0.3)), /// shadow color
                    radius: CGFloat(shadowRadius), /// shadow radius
                    x: CGFloat(shadowXOffset), //0, /// x offset
                    y: CGFloat(shadowYOffset) //2 /// y offset
                )
        } else {
            TheText(wordCell: wordCell)
        }
    }
}

// refer:
// title title2 : landscape
// headline callout : portrait
fileprivate struct TheText: View {
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor.withAlphaComponent(0.3))!
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
    
    @AppStorage(FontKey) private var fontData: Data = fontToData(NSFont.systemFont(ofSize: 18.0))!
    var font: Font {
        Font(dataToFont(fontData)!)
    }
    
    @AppStorage(FontRateKey) private var fontRate: Double = 0.6
    var transFont: Font {
        let font = dataToFont(fontData)!
        let result = NSFont.init(name: font.fontName, size: font.pointSize * CGFloat(fontRate))!
        return Font(result)
    }
    
    let wordCell: WordCell

    var unKnown: Bool {
        wordCell.isKnown == .unKnown
    }
    
    var word: String {
        wordCell.word
    }
    
    var trans: String {
        wordCell.trans
    }
    
    @AppStorage(IsTranslationDropFirstWordKey) private var isTranslationDropFirstWord: Bool = true
    var transText0: String {
        isTranslationDropFirstWord ?
            String(trans.dropFirst(word.count)) :
            trans
    }
    
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    var transText: String {
        isAddLineBreak ? "\n" + transText0 : trans
    }

    var body: Text {
        unKnown ?
            Text(word)
            .foregroundColor(theWordColor)
            .font(font)
            +
            Text(transText)
            .foregroundColor(theTransColor)
            .font(transFont)
            :
            
            Text(word)
            .foregroundColor(theKnownWordColor)
            .font(font)
    }
}

//struct SingleWordView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleWordView()
//    }
//}
