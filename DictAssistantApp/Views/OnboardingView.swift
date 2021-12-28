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
                Text("We start with three steps to setup.")
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
                Text("Initialize your English vocabulary count, press return")
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
                                    message: Text("Count must be an integer, and must between \(minEnWikiCount) and \(maxEnWikiCount), including."),
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
                    Text("This step is optional, but highly recommended.")
                        .font(.footnote)
                    Text("It may takes about 10 to 30 seconds to build.")
                        .font(.footnote)
                }
            },
            content: {
                GroupBox {
                    VStack {
                        Picker("Your Target Language:", selection: $lang) {
                            ForEach(Lang.allCases, id: \.self) { lang in
                                Text(NSLocalizedString(lang.rawValue, comment: "")).tag(lang)
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
        Text("If you are in China mainland, you may have issue downloading and build the dictionary, because the source dictionary file are located at https://github.com/gaozhanting/CsvDicts and the CDN may be very slow sometimes. You could wait some longer time.\n\nOr you can skip this step. Instead, you can manually download the csv file in browser with the CDN link: https://cdn.jsdelivr.net/gh/gaozhanting/CsvDicts@main/ChineseSimplified.csv, the file size is about 17M, and it may take a while. And then, build it later using local file from the App menubar/Dictionary/Show Dict Build Panel/Rebuild From Local File/Open the downloaded file and build.")
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
            title: { Text("Initialize one global keyboard shortcuts, playing") },
            content: {
                OneKeyRecordingView()
                    .frame(width: 500)
                
                if showPlaying {
                    VStack(alignment: .leading) {
                        Divider()
                        Text("Playing:")
                            .padding(.bottom)
                        Text("Step 1: Press the shortcut key and adjust the cropper window and content window.")
                        Text("The cropper window has an animation stoke border. Please don't overlap them.")
                            .font(.subheadline)
                            .padding(.bottom)
                        Text("Step 2: Press the shortcut key and playing. (Need Screen Recording Permission)")
                        Divider()
                            .padding(.top)
                        Text("Stop:")
                            .padding(.bottom)
                        Text("Press the shortcut key to stop playing.")
                    }
                    .padding(.vertical)
                    .frame(width: 500)
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
                Text("Run Step Play")
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
            //        .environment(\.locale, .init(identifier: "zh-Hans"))
            .environment(\.locale, .init(identifier: "en"))
            .frame(width: 650, height: 530 - 28) // 28 is the height of title bar
            
            
            ChineseMainlandIssueView()
        }
    }
}
