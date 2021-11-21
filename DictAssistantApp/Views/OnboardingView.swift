//
//  OnboardingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/15.
//

import SwiftUI
import KeyboardShortcuts

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
//                        .transition(AnyTransition.asymmetric(
//                                        insertion: .move(edge: .trailing),
//                                        removal: .move(edge: .leading))
//                        )
//                        .animation(.default)
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
                    .font(.title3)
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

private struct WelcomeView: View {
    let next: () -> Void

    var body: some View {
        PageTemplateView(
            title: { Text("Welcome to English Assistant App") },
            content: {
                Text("We start three steps to setup.")
            },
            nextButton: {
                Button("Continue", action: next)
            })
    }
}

private struct InitKnownView: View {
    let next: () -> Void
    
    @State private var count: String = String(defaultEnWikiCount)
    @State var showingAlert: Bool = false
    @State private var batchInsertSucceed: Bool = false

    @FetchRequest(
        entity: Known.entity(),
        sortDescriptors: []
    ) var fetchedKnown: FetchedResults<Known>
    
    func onCommit() {
        if !validateEnWikiCountField(count) {
            showingAlert = true
            return
        }
        
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

private func defaultSelectedDictNameFromSystemPreferredLanguage() -> String {
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

private struct InstallPresetDictView: View {
    let next: () -> Void
    
    @State var selectedDictName: String = defaultSelectedDictNameFromSystemPreferredLanguage()

    var body: some View {
        PageTemplateView(
            title: {
                VStack {
                    Text("Install recommended concise dictionary")
                    Text("If have multi, install which you like.")
                        .font(.footnote)
                    Text("This step is optional, but highly recommended.")
                        .font(.footnote)
                }
            },
            content: {
                VStack(alignment: .leading) {
                    Text("Step 1: Open Dictionary App, click menu File/Open Dictionaries Folder.")
                    HStack {
                        Spacer()
                        Text("This action will create the folder if not have been created before.")
                            .font(.subheadline)
                        Spacer()
                    }
                    Button("Open Dictionary App") {
                        openAppleDictionrayApp()
                    }
                    .font(.body)
                    
                    Spacer()
                    
                    HStack {
                        Text("Step 2:")
                        GroupBox {
                            DictInstallView(dicts: targetDicts())
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Step 3: Restart Dictionary App, open preferences, drag the installed dict to the top as the first selected dictionary.")
                }
                .padding(.vertical, 40)
            },
            nextButton: {
                Button("Continue", action: next)
            })
    }
}

private func openAppleDictionrayApp() {
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Dictionary") else { return }
    NSWorkspace.shared.openApplication(
        at: url,
        configuration: NSWorkspace.OpenConfiguration(),
        completionHandler: nil)
}

private struct InitGlobalKeyboardShortcutView: View {
    let next: () -> Void
    @Environment(\.endOnboarding) var endOnboarding
    @AppStorage(IsFinishedOnboardingKey) private var isFinishedOnboarding: Bool = false
    
    @State private var showPlaying: Bool = false
    
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
                            .padding(.bottom, 8)
                        Text("Step 1: Press Run Step Play keyboard shortcut key and adjust the cropper window and the content window.")
                        Text("The cropper window has an animation stoke border, the content window has a translucency and vibrancy effect. Don't overlap them.")
                            .font(.subheadline)
                            .padding(.bottom, 4)
                        Text("Step 2: Press Run Step Play keyboard shortcut key and playing. (Need Screen Recording Permission)")
                        Divider()
                            .padding(.top, 4)
                        Text("Stop:")
                            .padding(.bottom, 8)
                        Text("Press Run Step Play keyboard shortcut key to stop playing.")
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
                KeyboardShortcuts.Recorder(for: .toggleStepPlay)
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
    case installPresetDict
    case initGlobalKeyboardShortcut
    
    @ViewBuilder
    func view(next: @escaping () -> Void = {}) -> some View {
        switch self {
        case .welcome:
            WelcomeView(next: next)
        case .initKnown:
            InitKnownView(next: next)
        case .installPresetDict:
            InstallPresetDictView(next: next)
        case .initGlobalKeyboardShortcut:
            InitGlobalKeyboardShortcutView(next: next)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingPage.welcome.view()
            OnboardingPage.initKnown.view()
            OnboardingPage.installPresetDict.view()
            OnboardingPage.initGlobalKeyboardShortcut.view()
        }
        .environment(\.locale, .init(identifier: "zh-Hans"))
//        .environment(\.locale, .init(identifier: "en"))
        .frame(width: 650, height: 530 - 28) // 28 is the height of title bar
    }
}
