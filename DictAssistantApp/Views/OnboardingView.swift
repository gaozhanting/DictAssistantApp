//
//  OnboardingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/15.
//

import SwiftUI
import KeyboardShortcuts

fileprivate struct PageTemplateView<Title: View, Content: View, NextButton: View>: View {
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
                    .frame(width: 500)
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

fileprivate struct WelcomeView: View {
    let next: () -> Void

    var body: some View {
        PageTemplateView(
            title: { Text("Welcome to DictAssistant") },
            content: {
                Text("We start three steps to setup.")
            },
            nextButton: {
                Button(action: next) {
                    Text("Continue")
                }
            })
    }
}

fileprivate struct InitKnownView: View {
    let next: () -> Void
    
    @State private var to: Int = 5000
    @State private var showAddButton: Bool = false
    @State private var batchInsertSucceed: Bool = false
    
    @FetchRequest(
        entity: Known.entity(),
        sortDescriptors: []
    ) var fetchedKnown: FetchedResults<Known>
    
    var body: some View {
        PageTemplateView(
            title: { Text("Initialize your English vocabulary") },
            content: {
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
                        batchInsertKnown(words) {
                            batchInsertSucceed = true
                        }
                    }) {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                    .disabled(!showAddButton)
                }
            },
            nextButton: {
                Button(action: next, label: {
                    Text("Continue")
                })
                .disabled(fetchedKnown.count == 0 && !batchInsertSucceed)
            })
    }
}

func defaultSelectedDictNameFromSystemPreferredLanguage() -> String {
    for language in Locale.preferredLanguages {
//        if language.contains("zh-Hans") { return "英漢字典CDic" } // for testing
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
        PageTemplateView(
            title: {
                VStack {
                    Text("Install recommened concise dictionary. (If have multi, select one or install all.)")
                    Text("This step is optional, but highly recommended.")
                        .font(.footnote)
                }
            },
            content: {
                VStack(alignment: .leading) {
                    GroupBox {
                        DictInstallView(dicts: targetDicts())
                            .frame(maxWidth: .infinity)
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    Text("Open Dictionary App preferences, make it the first selected dictionary.")
                    Button("Open Dictionary App") {
                        openDict("")
                    }
                }
                .padding()
            },
            nextButton: {
                Button(action: next, label: {
                    Text("Continue")
                })
            })
    }
}

fileprivate struct InitGlobalKeyboardShortcutView: View {
    let next: () -> Void
    @Environment(\.endOnboarding) var endOnboarding
    @AppStorage(IsFinishedOnboardingKey) private var isFinishedOnboarding: Bool = false
    
    func allSet() -> Bool {
        (KeyboardShortcuts.getShortcut(for: .toggleStepPlay) != nil) &&
        (KeyboardShortcuts.getShortcut(for: .toggleShowCurrentKnown) != nil)
    }
    
    @State private var showPlaying: Bool = false
    
    var body: some View {
        PageTemplateView(
            title: { Text("Initialize two global keyboard shortcuts & Playing") },
            content: {
                KeyRecordingView(onboarding: true)
                    .frame(width: 500)
                
                if showPlaying {
                    VStack(alignment: .leading) {
                        Divider()
                        Text("Playing:")
                        Text("Step 1: Press Toggle Flow Step keyboard shortcut key and adjust the cropper window.")
                        Text("Step 2: Press Toggle Flow Step keyboard shortcut key and adjust the content window.")
                        Text("Step 3: Press Toggle Flow Step keyboard shortcut key and playing. (Need Screen Recording Permission)")
                        Divider()
                        Text("Stop:")
                        Text("Press Toggle Flow Step keyboard shortcut key to stop playing.")
                    }
                    .frame(width: 500)
                }
            },
            nextButton: {
                if !showPlaying {
                    Button(action: {
                        showPlaying = true
                        isFinishedOnboarding = true
                    }, label: {
                        Text("Continue")
                    })
                    .disabled(!allSet())
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

enum OnboardingPage: CaseIterable {
    case welcome
    case initKnown
    case downloadExtraDict
    case initGlobalKeyboardShortcut
    
    @ViewBuilder
    func view(next: @escaping () -> Void = {}) -> some View {
        switch self {
        case .welcome:
            WelcomeView(next: next)
        case .initKnown:
            InitKnownView(next: next)
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
            OnboardingPage.welcome.view()
            OnboardingPage.initKnown.view()
            OnboardingPage.downloadExtraDict.view()
            OnboardingPage.initGlobalKeyboardShortcut.view()
        }
//        .environment(\.locale, .init(identifier: "zh-Hans"))
        .frame(width: 650, height: 530 - 28) // 28 is the height of title bar
    }
}
