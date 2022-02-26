//
//  OnboardingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/15.
//

import SwiftUI
import KeyboardShortcuts
import DataBases

struct OnboardingView: View {

    @State var currentPage: OnboardingPage = .welcome
    let pages: [OnboardingPage]
    
    init(pages: [OnboardingPage]) {
        self.pages = pages
    }
    
    var body: some View {
        VStack {
            ForEach(pages, id: \.self) { page in
                if page == currentPage {
                    page.view(next: showNextPage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    func showNextPage() {
        guard let currentIndex = pages.firstIndex(of: currentPage), pages.count > currentIndex + 1 else {
            return
        }
        currentPage = pages[currentIndex + 1]
    }
}

private struct PageTemplateView<Title: View, Content: View, NextButton: View>: View {
    let title: Title
    let content: Content
    let nextButton: NextButton
    
    init(
        @ViewBuilder title: () -> Title,
        @ViewBuilder content: () -> Content,
        @ViewBuilder nextButton: () -> NextButton) {
        self.title = title()
        self.content = content()
        self.nextButton = nextButton()
    }
    
    var body: some View {
        VStack {
            title
                .font(.largeTitle)
                .frame(alignment: .top)
                .padding()
            
            Divider()
            
            VStack {
                Spacer()
                content
                    .frame(width: 650)
                Spacer()
            }
            
            HStack {
                nextButton
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(VisualEffectView(material: .underPageBackground))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct WelcomeView: View {
    let next: () -> Void

    var body: some View {
        PageTemplateView(
            title: { Text("Welcome to Freedom English App") },
            content: {
                Text("We start off with three steps.")
            },
            nextButton: {
                Button("Continue", action: next)
            })
    }
}

private struct InitKnownView: View {
    let next: () -> Void
    
    @State var count: String = String(defaultEnWikiCount)
    @State var showingAlert: Bool = false
    @State var batchInsertSucceed: Bool = false

    @FetchRequest(
        entity: Known.entity(),
        sortDescriptors: []
    ) var fetchedKnown: FetchedResults<Known>
    
    func onCommit() {
        if !validateEnWikiCountField(count) {
            showingAlert = true
            return
        }
        
        let wikiFrequencyWords = Vocabularies.readToArray(from: "first_100_000_of_enwiki-20190320-words-frequency.txt")
        
        let words = Array(wikiFrequencyWords[0 ..< Int(count)!])
        batchDeleteAllKnown {
            batchInsertKnown(words) {
                batchInsertSucceed = true
            }
        }
    }
    
    var body: some View {
        PageTemplateView(
            title: {
                VStack {
                    Text("Initialize your English vocabulary")
                    Text("Estimate a number, and then press return key to complete.")
                        .font(.body)
                }
            },
            content: {
                GroupBox {
                    HStack {
                        Text("My vocabulary count:")
                        TextField("", text: $count, onCommit: onCommit)
                            .frame(width: 60)
                            .alert(isPresented: $showingAlert) {
                                Alert(
                                    title: Text("Invalid value"),
                                    message: Text("Count must be an integer, and must between 1 and 100000, including."),
                                    dismissButton: .destructive(
                                        Text("Cancel"),
                                        action: { count = String(defaultEnWikiCount) }
                                    )
                                )
                            }
                    }
                    .padding()
                }
            },
            nextButton: {
                Button("Continue", action: next)
                    .disabled(fetchedKnown.count == 0 && !batchInsertSucceed)
            })
    }
}

private enum Lang: String, CaseIterable {
    case Arabic
    case ChineseSimplified
    case ChineseTraditional
    case Dutch
    case English
    case French
    case German
    case Greek
    case Hebrew
    case Hindi
    case Italian
    case Japanese
    case Korean
    case Portuguese
    case Russian
    case Spanish
    case Swedish
    case Turkish
    case None
}

private func nativeLanguageName(lang: Lang) -> String {
    switch lang {
    case .Arabic: return "عربي"
    case .ChineseSimplified: return "简体中文"
    case .ChineseTraditional: return "繁體中文"
    case .Dutch: return "Nederlands"
    case .English: return "English"
    case .French: return "français"
    case .German: return "Deutsch"
    case .Greek: return "Ελληνικά"
    case .Hebrew: return "עִברִית"
    case .Hindi: return "हिन्दी"
    case .Italian: return "Italiana"
    case .Japanese: return "日本"
    case .Korean: return "한국어"
    case .Portuguese: return "português"
    case .Russian: return "русский"
    case .Spanish: return "Española"
    case .Swedish: return "svenska"
    case .Turkish: return "Türk"
    case .None: return "None"
    }
}

// to be tested
private func systemLanguage() -> Lang {
    for language in Locale.preferredLanguages {
        if language.contains("zh-Hans") { return .ChineseSimplified }
        if language.contains("zh-Hant") { return .ChineseTraditional }
        if language.contains("ja") { return .Japanese }
        if language.contains("ko") { return .Korean }
        if language.contains("de") { return .German }
        if language.contains("fr") { return .French }
        if language.contains("es") { return .Spanish }
        if language.contains("pt") { return .Portuguese }
        if language.contains("it") { return .Italian }
        if language.contains("nl") { return .Dutch }
        if language.contains("sv") { return .Swedish }
        if language.contains("ru") { return .Russian }
        if language.contains("el") { return .Greek }
        if language.contains("tr") { return .Turkish }
        if language.contains("he") { return .Hebrew }
        if language.contains("ar") { return .Arabic }
        if language.contains("hi") { return .Hindi }
        if language.contains("en") { return .English }
    }
    
    return .None
}

private struct BuildDictView: View {
    let next: () -> Void

    @State var lang: Lang = systemLanguage()
    
    var body: some View {
        PageTemplateView(
            title: {
                VStack {
                    Text("Build local concise dictionary")
                    Group {
                        Text("Select your target language, then click the hammer button below, it takes about 10 to 30 seconds.")
                            .multilineTextAlignment(.center)
                        Text("It will prompt succeed when completed.")
                        Text("This step is optional, but highly recommended.")
                    }
                    .font(.body)
                }
            },
            content: {
                GroupBox {
                    VStack {
                        Picker("Your target language:", selection: $lang) {
                            ForEach(Lang.allCases, id: \.self) { lang in
                                Text(nativeLanguageName(lang: lang)).tag(lang)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 360)
                        
                        if lang != .None {
                            HStack {
                                BuildActionView(
                                    buildFrom: lang == .ChineseSimplified ? "https://cdn.jsdelivr.net/gh/gaozhanting/CsvDicts@main/ChineseSimplified.csv" : "https://github.com/gaozhanting/CsvDicts/raw/main/\(lang.rawValue).csv")
                                
                                if lang == .ChineseSimplified {
                                    MiniInfoView {
                                        ChineseMainlandIssueView()
                                    }
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding()
                }
            },
            nextButton: {
                Button("Continue", action: next)
            }
        )
    }
}

private struct ChineseMainlandIssueView: View {
    var body: some View {
        Text("If you are in China mainland, you may have issue downloading and build the dictionary, because the source dictionary file are located at https://github.com/gaozhanting/CsvDicts/raw/main/ChineseSimplified.csv and the CDN may be very slow sometimes. You could wait some longer time.\n\nOr you can skip this step. Instead, you can manually download the csv file in browser with the CDN link: https://cdn.jsdelivr.net/gh/gaozhanting/CsvDicts@main/ChineseSimplified.csv, the file size is about 17M, and it may take a while. And then, build it later using local file from the App menubar/Dictionary/Show Dict Build Panel/Rebuild From Local File/Open the downloaded file and build.")
            .infoStyle()
    }
}

private struct InitGlobalKeyboardShortcutView: View {
    let next: () -> Void
    @Environment(\.endOnboarding) var endOnboarding
    @AppStorage(IsFinishedOnboardingKey) var isFinishedOnboarding: Bool = false
    
    @State var showPlaying: Bool = false
    
    var body: some View {
        PageTemplateView(
            title: {
                VStack {
                    Text("Initialize one global keyboard shortcut, playing")
                    Group {
                        Text("Click the right box, and then press a shortcut key. Recommend Option-1.")
                        Text("If it shows your key, then succeed; otherwise you need press another shortcut key because the one you just pressed was already used by system or some other Apps.")
                            .multilineTextAlignment(.center)
                    }
                    .font(.body)
                }
            },
            content: {
                OneKeyRecordingView()
                    .frame(width: 500)
                
                if showPlaying {
                    VStack(alignment: .leading) {
                        Divider()
                        Text("How to Play:")
                            .padding(2)
                        Text("Step 1: Press the shortcut key and adjust the cropper window and the content window.")
                        Text("The cropper window has an animation stoke border. The cropper area is the area where the English text in screen you want to be recognized, the content area is the area where you want to locate the corresponding unknown words translation. Please don't overlap them.")
                            .frame(height: 50)
                            .font(.subheadline)
                        Text("Step 2: Press the shortcut key again and playing. (Need Screen Recording Permission First time)")
                        Divider()
                        Text("How to Stop:")
                            .padding(2)
                        Text("When playing, press the same shortcut key to stop.")
                    }
                    .padding()
                }
            },
            nextButton: {
                if !showPlaying {
                    Button(action: {
                        withAnimation {
                            showPlaying = true
                        }
                        isFinishedOnboarding = true
                        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String // not nil
                        UserDefaults.standard.setValue(appVersion, forKey: "CurrentVersion")
                    }, label: {
                        Text("Continue")
                    })
                } else {
                    Button(action: {
                        endOnboarding()
                    }, label: {
                        Text("End")
                    })
                }
            }
        )
    }
}

private struct OneKeyRecordingView: View {
    var body: some View {
        GroupBox {
            HStack {
                Text("Run step play")
                Spacer()
                KeyboardShortcuts.Recorder(for: .runStepPlay)
                MiniInfoView {
                    Text("recommend: Option-1").font(.subheadline).padding()
                }
            }
            .padding()
        }
    }
}

enum OnboardingPage: CaseIterable {
    case welcome
    case initKnown
    case buildDict
    case initGlobalKeyboardShortcut
    
    @ViewBuilder
    func view(next: @escaping () -> Void = {}) -> some View {
        switch self {
        case .welcome:
            WelcomeView(next: next)
        case .initKnown:
            InitKnownView(next: next)
        case .buildDict:
            BuildDictView(next: next)
        case .initGlobalKeyboardShortcut:
            InitGlobalKeyboardShortcutView(next: next)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                OnboardingPage.welcome.view()
                OnboardingPage.initKnown.view()
                OnboardingPage.buildDict.view()
                OnboardingPage.initGlobalKeyboardShortcut.view()
                
            }
            .frame(width: 650, height: 530 - 28) // 28 is the height of title bar
            
            ChineseMainlandIssueView()
        }
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
