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
            VStack(alignment: .leading) {
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
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    var theBackgroundColor: Color {
        Color(dataToColor(backgroundColor)!)
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

    var body0: some View {
        TextWithShadow(wordCell: wordCell)
            .opacity( (known && isPhrase) ? 0.5 : 1)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .contextMenu {
                Button(unKnown ? "Add to Known" : "Remove from known", action: {
                    unKnown ? addToKnownWords(word) : removeFromKnownWords(word)
                })
                Button("Edit Custom Dict Entry", action: {
                    showEditingCustomDictEntryPopover = true
                })
                Menu("Online Dict Link") {
                    Button("Collins", action: { openCollins(word) })
                    Button("Cambridge", action: { openCambridge(word) })
                    Button("Lexico", action: { openLexico(word) })
                    Button("Dictionary", action: { openDictionary(word) })
                    Button("Thesaurus", action: { openThesaurus(word) })
                }
            }
            .popover(isPresented: $showEditingCustomDictEntryPopover) {
                    EditCustomDictEntryView(word: word)
            }
            .gesture(
                TapGesture()
                    .modifiers(.option)
                    .onEnded { _ in
                        unKnown ? addToKnownWords(word) : removeFromKnownWords(word)
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
    
    @State private var showEditingCustomDictEntryPopover: Bool = false
    
    var body: some View {
        if contentStyle == .landscape {
            body0
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(isAddBackGround ? theBackgroundColor : nil)
        } else {
            body0
                .background(isAddBackGround ? theBackgroundColor : nil)
        }
    }
    
    // Add background when landscape or portrait-bottomLeading, when disabled the visual effect.
    var isAddBackGround: Bool {
        !contentBackgroundVisualEffect &&
            (contentStyle == .landscape ||
                (contentStyle == .portrait && portraitCorner == .bottomLeading))
    }
    
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topTrailing
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
}

fileprivate struct EditCustomDictEntryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let word: String
    @State private var trans: String = ""
    
    func add() {
        let entry = Entry(word: word, trans: trans)
        upsertCustomDict(entry: entry)
    }
    
    func remove() {
        removeCustomDict(word: word)
    }
    
    var body: some View {
        HStack {
            TextField("Edit The Translation Of Word: \(word)", text: $trans)
            
            Button(action: add) {
                Image(systemName: "rectangle.badge.plus")
            }
            .disabled(trans.isMultiline)
            .keyboardShortcut(KeyEquivalent.return) // command + return
            
            Button(action: remove) {
                Image(systemName: "rectangle.badge.minus")
            }
            .keyboardShortcut(KeyEquivalent.delete) // command + delete
        }
        .frame(width: 380)
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

extension String {
    var isMultiline: Bool {
        self.contains { c in
            c.isNewline
        }
    }
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
                    color: Color(dataToColor(shadowColor)!),
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
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    var theWordColor: Color {
        Color(dataToColor(wordColor)!)
    }
    
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false

    var theKnownWordColor: Color {
        if isShowCurrentKnown {
            return theWordColor.opacity(0.5)
        }
        
        if isShowCurrentKnownButWithOpacity0 {
            return theWordColor.opacity(0)
        }
        
        return theWordColor.opacity(0) // impossible, refer to func convertToWordCellWithId
    }
    
    @AppStorage(IsConcealTranslationKey) private var isConcealTranslation: Bool = false
    var theTransColor: Color {
        Color(dataToColor(transColor)!)
            .opacity(isConcealTranslation ? 0 : 1)
    }
    
    @AppStorage(FontNameKey) private var fontName: String = defaultFontName
    @AppStorage(FontSizeKey) private var fontSize: Double = 18.0
    var font: Font {
        return Font.custom(fontName, size: CGFloat(fontSize))
    }
    
    @AppStorage(FontRateKey) private var fontRate: Double = 0.75
    var transFont: Font {
        return Font.custom(fontName, size: CGFloat(fontSize * fontRate))
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
    
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = false
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    var translation: String {
        let step1 = !isJoinTranslationLines ? trans : trans.replacingOccurrences(of: "\n", with: " ")
        let step2 = isDropFirstTitleWordInTranslation ?
            String(step1.dropFirst(word.count).drop { c in c.isWhitespace }) : // drop title word count character (commonly is the title word itself), and also drop whitespace after it.
            step1
        let step3 = isAddLineBreak ? "\n" + step2 : step2
        let step4 = isAddSpace ? " " + step3 : step3
        return step4
    }
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false
    var unKnownText: Text {
        !isDropTitleWord ?
            
            Text(word)
            .foregroundColor(theWordColor)
            .font(font)
            +
            Text(translation)
            .foregroundColor(theTransColor)
            .font(transFont) :
            
            Text(translation)
            .foregroundColor(theTransColor)
            .font(transFont)
    }
    
    var knownText: Text {
        Text(word)
            .foregroundColor(theKnownWordColor)
            .font(font)
    }
    
    var body: Text {
        unKnown ?
            unKnownText :
            knownText
    }
}

struct SingleWordView_Previews: PreviewProvider {
    static var previews: some View {
        EditCustomDictEntryView(word: "take off")
    }
}
