//
//  SingleWordView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/24.
//

import SwiftUI

struct SingleWordView: View {
    @AppStorage(ContentLayoutKey) var contentLayout: Int = ContentLayout.portrait.rawValue

    let wordCell: WordCell
    
    var body: some View {
        switch ContentLayout(rawValue: contentLayout)! {
        case .portrait:
            TextBody(wordCell: wordCell)
        case .landscape:
            if !wordCell.trans.isEmpty {
                switch LandscapeStyle(rawValue: landscapeStyle)! {
                case .normal, .autoScrolling:
                    TextBody(wordCell: wordCell)
                        .frame(
                            maxWidth: CGFloat(landscapeMaxWidth),
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                case .centered:
                    TextBody(wordCell: wordCell)
                        .frame(
                            maxWidth: CGFloat(landscapeMaxWidth),
                            alignment: .top
                        )
                }
            } else {
                TextBody(wordCell: wordCell)
            }
        }
    }
    
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 160.0
}

private struct TextBody: View {
    let wordCell: WordCell
    
    var word: String {
        wordCell.word
    }
    
    var isPhrase: Bool {
        word.isPhrase
    }
    
    var known: Bool {
        wordCell.isKnown == .known
    }
    
    var unKnown: Bool {
        wordCell.isKnown == .unKnown
    }
    
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
    
    func openLexico(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.lexico.com/en/definition/")
    }
    
    func openDictionary(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.dictionary.com/browse/")
    }
    
    func openThesaurus(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.thesaurus.com/browse/")
    }
    
    var body: some View {
        TextWithShadow(wordCell: wordCell)
            .opacity( (known && isPhrase) ? 0.5 : 1)
            .minimalistPadding()
            .contextMenu {
                Button(unKnown ? "Add to Known" : "Remove from Known", action: {
                    unKnown ? addKnown(word) : removeKnown(word)
                })
                Button(!noisesSet.contains(word) ? "Add to Noises" : "Remove from Noises") {
                    !noisesSet.contains(word) ?
                        addNoise(word) :
                        removeNoise(word)
                }
                Menu("Online Dict Link") {
                    Button("Collins", action: { openCollins(word) })
                    Button("Cambridge", action: { openCambridge(word) })
                    Button("Lexico", action: { openLexico(word) })
                    Button("Dictionary", action: { openDictionary(word) })
                    Button("Thesaurus", action: { openThesaurus(word) })
                }
            }
            .gesture(
                TapGesture()
                    .modifiers(.option)
                    .onEnded { _ in
                        unKnown ? addKnown(word) : removeKnown(word)
                    }
            )
            .gesture(
                TapGesture()
                    .modifiers(.command)
                    .onEnded { _ in
                        say(word)
                    }
            )
            .gesture(
                TapGesture()
                    .modifiers(.shift)
                    .onEnded { _ in
                        openDict(word)
                    }
            )
    }
}

private func say(_ word: String) {
    let task = Process()
    task.launchPath = "/usr/bin/say"
    var arguments = [String]();
    arguments.append(word)
    task.arguments = arguments
    task.launch()
}

private func openDict(_ word: String) {
    let replaceSpaced = word.replacingOccurrences(of: " ", with: "-")
    let task = Process()
    task.launchPath = "/usr/bin/open"
    var arguments = [String]();
    arguments.append("dict://\(replaceSpaced)")
    task.arguments = arguments
    task.launch()
}

private struct TextWithShadow: View {
    @AppStorage(ShadowColorKey) var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) var shadowXOffset: Double = 0
    @AppStorage(ShadowYOffSetKey) var shadowYOffset: Double = 2

    @AppStorage(UseTextShadowKey) var useTextShadow: Bool = false
    
    let wordCell: WordCell
    
    var body: some View {
        if useTextShadow {
            TextWithLineSpacing(wordCell: wordCell)
                .shadow(
                    color: Color(dataToColor(shadowColor)!),
                    radius: CGFloat(shadowRadius), /// shadow radius
                    x: CGFloat(shadowXOffset), //0, /// x offset
                    y: CGFloat(shadowYOffset) //2 /// y offset
                )
        } else {
            TextWithLineSpacing(wordCell: wordCell)
        }
    }
}

private struct TextWithLineSpacing: View {
    @AppStorage(LineSpacingKey) var lineSpacing: Double = 2.0
    let wordCell: WordCell
    
    var body: some View {
        TheText(wordCell: wordCell)
            .lineSpacing(CGFloat(lineSpacing))
    }
}

// refer:
// title title2 : landscape
// headline callout : portrait
private struct TheText: View {
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    var theWordColor: Color {
        Color(dataToColor(wordColor)!)
    }
    
    @AppStorage(IsShowKnownKey) var isShowKnown: Bool = false
    @AppStorage(IsShowKnownButWithOpacity0Key) var isShowKnownButWithOpacity0: Bool = false

    var theKnownWordColor: Color {
        if isShowKnown {
            return theWordColor.opacity(0.5)
        }
        
        if isShowKnownButWithOpacity0 {
            return theWordColor.opacity(0)
        }
        
        return theWordColor.opacity(0) // impossible, refer to func convertToWordCellWithId
    }
    
    @AppStorage(IsConcealTranslationKey) var isConcealTranslation: Bool = false
    var theTransColor: Color {
        Color(dataToColor(transColor)!)
            .opacity(isConcealTranslation ? 0 : 1)
    }
    
    @AppStorage(FontNameKey) var fontName: String = defaultFontName
    @AppStorage(FontSizeKey) var fontSize: Int = 14
    var font: Font {
        return Font.custom(fontName, size: CGFloat(fontSize))
    }
    
    @AppStorage(FontRatioKey) var fontRatio: Double = 0.9
    var transFont: Font {
        return Font.custom(fontName, size: CGFloat(fontSize) * CGFloat(fontRatio))
    }
    
    let wordCell: WordCell

    var unKnown: Bool {
        wordCell.isKnown == .unKnown
    }
    
    var word: String {
        wordCell.word
    }
    
    @AppStorage(ChineseCharacterConvertModeKey) var chineseCharacterConvertMode: Int = ChineseCharacterConvertMode.notConvert.rawValue
    var trans: String {
        switch ChineseCharacterConvertMode(rawValue: chineseCharacterConvertMode)! {
        case .notConvert:
            return wordCell.trans
        case .convertToTraditional:
            return wordCell.trans.big5
        case .convertToSimplified:
            return wordCell.trans.gb
        }
    }
    
    @AppStorage(IsJoinTranslationLinesKey) var isJoinTranslationLines: Bool = true
    @AppStorage(IsDropFirstTitleWordInTranslationKey) var isDropFirstTitleWordInTranslation: Bool = true
    @AppStorage(IsAddLineBreakKey) var isAddLineBreak: Bool = true
    @AppStorage(IsAddSpaceKey) var isAddSpace: Bool = false
    var translation: String {
        let step1 = !isJoinTranslationLines ? trans : trans.replacingOccurrences(of: "\n", with: " ")
        let step2 = isDropFirstTitleWordInTranslation ?
            String(step1.dropFirst(word.count).drop { c in c.isWhitespace }) : // drop title word count character (commonly is the title word itself), and also drop whitespace after it.
            step1
        let step3 = isAddLineBreak ? "\n" + step2 : step2
        let step4 = isAddSpace ? " " + step3 : step3
        return step4
    }
    
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightMode.dotted.rawValue
    @AppStorage(IsShowIndexKey) var isShowIndex: Bool = false
    var indexFont: Font {
        Font.custom(fontName, size: CGFloat(fontSize) * 0.6)
    }
    @AppStorage(ContentIndexColorKey) var contentIndexColor: Data = colorToData(NSColor.systemOrange)!
    var iColor: Color {
        Color(dataToColor(contentIndexColor)!)
    }
    
    var indexText: Text {
        switch HighlightMode(rawValue: highlightMode)! {
        case .dotted:
            if !isShowIndex {
                return Text("").foregroundColor(iColor).font(indexFont)
            }
            if wordCell.index == 0 {
                return Text("").foregroundColor(iColor).font(indexFont)
            } else {
                return Text("\(wordCell.index) ").foregroundColor(iColor).font(indexFont)
            }
        case .rectangle:
            return Text("")
        case .disabled:
            return Text("")
        }
    }
    
    @AppStorage(IsDropTitleWordKey) var isDropTitleWord: Bool = false
    var unKnownText0: Text {
        !isDropTitleWord ?
        Text(word).foregroundColor(theWordColor).font(font) + Text(translation).foregroundColor(theTransColor).font(transFont) :
        Text(translation).foregroundColor(theTransColor).font(transFont)
    }
    var unKnownText: Text {
        indexText + unKnownText0
    }
    
    var knownText: Text {
        Text(word).foregroundColor(theKnownWordColor).font(font)
    }
    
    var body: Text {
        unKnown ? unKnownText : knownText
    }
}
