//
//  SingleWordView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/24.
//

import SwiftUI

struct SingleWordView: View {
    @EnvironmentObject var contentWindowLayout: ContentWindowLayout
    
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = LandscapeMaxWidthDefault

    let wordCell: WordCell
    
    var body: some View {
        switch contentWindowLayout.layout {
        case .portrait:
            TextBody(wordCell: wordCell)
        case .landscape:
            if !wordCell.trans.isEmpty {
                switch LandscapeStyle(rawValue: landscapeStyle)! {
                case .scroll:
                    TextBody(wordCell: wordCell)
                        .frame(
                            maxWidth: CGFloat(landscapeMaxWidth),
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
}

private struct TextBody: View {
    let wordCell: WordCell
    
    var word: String {
        wordCell.word
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
    
    func openThesaurus(_ word: String) {
        openExternalDict(word, urlPrefix: "https://www.thesaurus.com/browse/")
    }
    
    var body: some View {
        TheText(wordCell: wordCell)
            .lineSpacinged()
            .minimalistPaddinged()
            .contextMenu {
                Button(unKnown ? "Add to Known" : "Remove from Known") {
                    unKnown ? addKnown(word) : removeKnown(word)
                }
                Button("Say") {
                    say(word)
                }
                Menu("Open At") {
                    Button("Local") { openDict(word) }
                    Button("Collins") { openCollins(word) }
                    Button("Cambridge") { openCambridge(word) }
                    Button("Lexico") { openLexico(word) }
                    Button("Thesaurus") { openThesaurus(word) }
                }
                Button(!noisesSet.contains(word) ? "Add to Noises" : "Remove from Noises") {
                    !noisesSet.contains(word) ? addNoise(word) : removeNoise(word)
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

private struct MinimalistPaddinged: ViewModifier {
    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    var isMinimalist: Bool {
        ContentPaddingStyle(rawValue: contentPaddingStyle) == .minimalist
    }
    
    @AppStorage(MinimalistVPaddingKey) var minimalistVPadding: Double = 2.0
    @AppStorage(MinimalistHPaddingKey) var minimalistHPadding: Double = 6.0
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, isMinimalist ? minimalistVPadding : 0)
            .padding(.horizontal, isMinimalist ? minimalistHPadding : 0)
    }
}
extension View {
    func minimalistPaddinged() -> some View {
        modifier(MinimalistPaddinged())
    }
}

private struct LineSpacinged: ViewModifier {
    @AppStorage(LineSpacingKey) var lineSpacing: Double = 2.0

    func body(content: Content) -> some View {
        content.lineSpacing(CGFloat(lineSpacing))
    }
}
extension View {
    func lineSpacinged() -> some View {
        modifier(LineSpacinged())
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

// refer:
// title title2 : landscape
// headline callout : portrait
private struct TheText: View {
    let wordCell: WordCell

    var unKnown: Bool {
        wordCell.isKnown == .unKnown
    }
    
    var word: String {
        wordCell.word
    }
    
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor)!
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
    
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
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

    @AppStorage(ChineseCharacterConvertModeKey) var chineseCharacterConvertMode: Int = ChineseCharacterConvertMode.notConvert.rawValue
    var ccTrans: String {
        switch ChineseCharacterConvertMode(rawValue: chineseCharacterConvertMode)! {
        case .notConvert:
            return wordCell.trans
        case .convertToTraditional:
            return wordCell.trans.big5
        case .convertToSimplified:
            return wordCell.trans.gb
        }
    }
    
    @AppStorage(IsAddLineBreakKey) var isAddLineBreak: Bool = true
    var translation: String {
        let step1 = ccTrans.replacingOccurrences(of: "\n", with: " ")
        let step2 = String(step1.dropFirst(word.count).drop { c in c.isWhitespace }) // drop title word count character (commonly is the title word itself), and also drop whitespace after it.
        let step3 = isAddLineBreak ? "\n" + step2 : " " + step2
        return step3
    }
    
    var indexFont: Font {
        Font.custom(fontName, size: CGFloat(fontSize) * 0.6)
    }
    
    @AppStorage(ContentIndexColorKey) var contentIndexColor: Data = colorToData(NSColor.systemOrange)!
    var iColor: Color {
        Color(dataToColor(contentIndexColor)!)
    }
    
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    @AppStorage(IsShowIndexKey) var isShowIndex: Bool = false
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
    
    var unKnownText0: Text {
        Text(word).foregroundColor(theWordColor).font(font) + Text(translation).foregroundColor(theTransColor).font(transFont)
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
