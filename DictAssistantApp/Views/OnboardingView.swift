//
//  OnboardingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/15.
//

import SwiftUI
import KeyboardShortcuts

fileprivate struct WelcomeView: View {
    let next: () -> Void

    var body: some View {
        VStack {
            Text("Welcome to DictAssistant")
                .font(.title)
            
            Divider()
                .padding()
            
            Text("We start three steps to setup.")
                .frame(width: 500)
            
            Button(action: next, label: {
                Text("Continue")
            })
        }
    }
}

fileprivate struct InitKnownWordsView: View {
    let next: () -> Void
    
    @Environment(\.addMultiToKnownWords) var addMultiToKnownWords

    @State private var to: Int = 5000
    @State private var showAddButton: Bool = false
    
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.word, ascending: true)
        ]
    ) var fetchedKnownWords: FetchedResults<WordStats>

    var body: some View {
        VStack {
            Text("Initialize your English vocabulary")
                .font(.title)
            
            Divider()
                .padding()
            
            Text("Enter your estimated English vocabulary count, press enter key to commit. And then press add button, wait for contine.")
                .frame(width: 500)
            
            HStack {
                Text("My vocabulary count:")
                
                TextField("", value: $to, formatter: {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .none // integer, no decimal
                    formatter.minimum = 2
                    formatter.maximum = 100000
                    return formatter
                }(), onCommit: {
                    showAddButton = true
                })
                .frame(width: 60)
                
                Button(action: {
                    let words = Array(wikiFrequencyWords[0 ..< to])
                    addMultiToKnownWords(words)
                }) {
                    Image(systemName: "rectangle.stack.badge.plus")
                }
                .disabled(!showAddButton)
            }
            
            Button(action: next, label: {
                Text("Continue")
            })
            .disabled(fetchedKnownWords.count == 0)
        }
    }
}

func defaultSelectedDictNameFromSystemPreferredLanguage() -> String {
    for language in Locale.preferredLanguages {
        if language.contains("zh-Hans") { return "简明英汉字典增强版" }
        if language.contains("zh-Hant") { return "英漢字典CDic" }
        if language.contains("ja") { return "JMDict English-Japanese dictionary" }
        if language.contains("ko") { return "Babylon English-Korean dictionary" }
        if language.contains("de") { return "Babylon English-German dictionary" }
        if language.contains("fr") { return "Babylon English-French dictionary" }
        if language.contains("es") { return "Babylon English-Spanish dictionary" }
        if language.contains("pt") { return "Babylon English-Portuguese dictionary" }
        if language.contains("it") { return "Babylon English-Italian dictionary" }
        if language.contains("nl") { return "Babylon English-Dutch dictionary" }
        if language.contains("sv") { return "Babylon English-Swedish dictionary" }
        if language.contains("ru") { return "Babylon English-Russian dictionary" }
        if language.contains("el") { return "Babylon English-Greek dictionary" }
        if language.contains("tr") { return "Babylon English-Turkish dictionary" }
        if language.contains("he") { return "Babylon English-Hebrew dictionary" }
        if language.contains("ar") { return "Babylon English-Arabic dictionary" }
        if language.contains("hi") { return "English-Hindi Shabdanjali Dictionary" }
    }
    
    // fall to en
    return "Concise Oxford English Dictionary 11th"
}

fileprivate struct DownloadExtraDictView: View {
    let next: () -> Void
    
    @State var selectedDictName: String = defaultSelectedDictNameFromSystemPreferredLanguage()

    var body: some View {
        VStack {
            Text("Download and install recommened concise dictionary")
                .font(.title)
            
            Divider()
                .padding()
            
            Text("Select the dictionary of English to your native language. Download and install. Then open Apple Dictionary App preferences, make it the first selected dictionary.")
                .frame(width: 500)
            
            Text("This step is optional, but highly recommended.")
                .font(.footnote)
            
            Picker("Select:", selection: $selectedDictName) {
                ForEach(dicts, id:\.self.name) { dict in
                    Text(dict.name).tag(dict.name)
                }
            }
            .frame(width: 500)
            
            DictItemView(dict: dicts.first { $0.name == selectedDictName }!)
                .frame(width: 500)
            
            Button(action: next, label: {
                Text("Continue")
            })
        }
    }
}

fileprivate struct InitGlobalKeyboardShortcutView: View {
    let next: () -> Void
    @Environment(\.endOnboarding) var endOnboarding
    @AppStorage(IsFinishedOnboardingKey) private var isFinishedOnboarding: Bool = false
    
    func allSet() -> Bool {
        (KeyboardShortcuts.getShortcut(for: .toggleFlowStep) != nil) &&
        (KeyboardShortcuts.getShortcut(for: .toggleShowCurrentKnownWords) != nil)
    }
    
    @State private var showPlaying: Bool = false
    
    var body: some View {
        VStack {
            Text("Initialize three global keyboard shortcut & Playing")
                .font(.title)
            
            Divider()
                .padding()
            
            KeyRecordingView(onboarding: true)
            
            Button(action: {
                showPlaying = true
            }, label: {
                Text("Continue")
            })
            .disabled(!allSet())
            
            if showPlaying {
                VStack(alignment: .leading) {
                    Text("Playing:")
                    Text("Step 1: Press Toggle Flow Step shortcut key and adjust the cropper window.")
                    Text("Step 2: Press Toggle Flow Step shortcut key and adjust the content window.")
                    Text("Step 3: Press Toggle Flow Step shortcut key and playing.")
                    Divider()
                    Text("Stop:")
                    Text("Press Toggle Flow Step shortcut key to stop playing.")
                }
                .frame(width: 500)
                
                Button(action: {
                    endOnboarding()
                    isFinishedOnboarding = true
                }, label: {
                    Text("End")
                })
            }
        }
    }
}

enum OnboardingPage: CaseIterable {
    case welcome
    case initKnownWords
    case downloadExtraDict
    case initGlobalKeyboardShortcut
    
    @ViewBuilder
    func view(next: @escaping () -> Void = {}) -> some View {
        switch self {
        case .welcome:
            WelcomeView(next: next)
        case .initKnownWords:
            InitKnownWordsView(next: next)
        case .downloadExtraDict:
            DownloadExtraDictView(next: next)
        case .initGlobalKeyboardShortcut:
            InitGlobalKeyboardShortcutView(next: next)
        }
    }
}

struct OnboardingView: View {

    @State private var currentPage: OnboardingPage = .welcome
    private let pages: [OnboardingPage]
    
    init(pages: [OnboardingPage]) {
        self.pages = pages
    }
    
    var body: some View {
        VStack {
            ForEach(pages, id: \.self) { page in
                if page == currentPage {
                    page.view(next: showNextPage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(AnyTransition.asymmetric(
                                        insertion: .move(edge: .trailing),
                                        removal: .move(edge: .leading))
                        )
                        .animation(.default)
                }
            }
        }
    }
    
    private func showNextPage() {
        guard let currentIndex = pages.firstIndex(of: currentPage), pages.count > currentIndex + 1 else {
            return
        }
        currentPage = pages[currentIndex + 1]
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingPage.initGlobalKeyboardShortcut.view()

            OnboardingPage.initGlobalKeyboardShortcut.view()
                .environment(\.locale, .init(identifier: "zh-Hans"))
            
            OnboardingPage.initGlobalKeyboardShortcut.view()
                .environment(\.locale, .init(identifier: "zh-Hant"))
        }
        .frame(width: 650, height: 530 - 28) // 28 is the height of title bar
    }
}
