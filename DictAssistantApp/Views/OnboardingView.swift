//
//  OnboardingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/15.
//

import SwiftUI

fileprivate struct WelcomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to DictAssistant")
                .font(.title)
            
            Divider()
                .padding()
            
            Text("DictAssistant is a menu bar APP for assisting you reading English. It will automatically lookup your unknown English words and show the translation while you are reading. This way you release your hands.")
                .frame(width: 500)
        }
    }
}

fileprivate struct InitKnownWordsView: View {
    let next: () -> Void
    
    @Environment(\.addMultiToKnownWords) var addMultiToKnownWords

    @State private var to: Int = 5000
    
    @State private var showContinue: Bool = false

    var body: some View {
        VStack {
            Text("Initialize your vocabulary")
                .font(.title)
            
            Divider()
                .padding()
            
            Text("You tell your current English vocabulary (your known words) number to the app, and the app will not show the translation of your known words when reading. Don't be panic, you can change it at any time from the app's menu bar menu `Show Known Words Panel`, it is just a words list text.\nYou initialize you vocabulary by guessing your vocabulary number. For example, may be you think it is 4000, and the app will make the the first 4000 words from `wiki english words frequency list` your vocabulary. This way, though it is not accurate, it does got a decent your current vocabulary. You can add to it or remove from it by a single word (often when you are reading from the context), or with word lists.")
                .frame(width: 500)
            
            HStack {
                Text("My vocabulary number:")
                
                TextField("", value: $to, formatter: {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .none // integer, no decimal
                    formatter.minimum = 2
                    formatter.maximum = 100000
                    return formatter
                }())
                .frame(width: 60)
                
                Button(action: {
                    let words = Array(wikiFrequencyWords[1 ..< to])
                    addMultiToKnownWords(words)
                    showContinue = true
                }) {
                    Image(systemName: "rectangle.stack.badge.plus")
                }
            }
            
            Button(action: next, label: {
                Text("Continue")
            })
            .disabled(!showContinue)
        }
    }
}

fileprivate struct DownloadExtraDictView: View {
    let next: () -> Void

    let d =
        Dict(name: "英漢字典CDic",
             sourceURL: URL(string: "http://download.huzheng.org/zh_TW/")!,
             license: "?",
             licenseURL: URL(string: "http://cview.com.tw/")!,
             installedName: "mac-yinghancidian.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/mac-yinghancidian.dictionary.zip")!
        )
    
    var body: some View {
        VStack {
            Text("Download extra concise dictionary")
                .font(.title)
            
            Divider()
                .padding()
            
            Text("blabla")
            
            DictItemView(
                name: d.name,
                sourceURL: d.sourceURL,
                license: d.license,
                licenseURL: d.licenseURL,
                installedName: d.installedName,
                downloadURL: d.downloadURL
            )
            .frame(width: 300)
            
            Button(action: next, label: {
                Text("Continue")
            })
        }
    }
}

enum OnboardingPage: CaseIterable {
    case welcome
    case initKnownWords
    case downloadExtraDict
    case initGlobalKeyboardShortcut
    
    var shouldShowNextButton: Bool {
        self == .welcome
    }
    
    var shouldShowEndButton: Bool {
        self == .initGlobalKeyboardShortcut
    }
    
    @ViewBuilder
    func view(next: @escaping () -> Void = {}) -> some View {
        switch self {
        case .welcome:
            WelcomeView()

        case .initKnownWords:
            InitKnownWordsView(next: next)

        case .downloadExtraDict:
            DownloadExtraDictView(next: next)
//            HStack {
//                Text("We need downloadExtraDict")
//
////                // This button should only be enabled once downloadExtraDict are set:
////                Button(action: action, label: {
////                    Text("Continue")
////                })
//            }
        case .initGlobalKeyboardShortcut:
            HStack {
                Text("Become PRO for even more features")
                
//                Button(action: {
//                    NSApplication.shared.stopModal()
//                }, label: {
//                    Text("OK")
//                })
            }
        }
    }
}

struct OnboardingView: View {
    @Environment(\.endOnboarding) var endOnboarding

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
//
//            HStack {
//                Spacer()
//                if currentPage.shouldShowNextButton {
//                    Button(action: showNextPage, label: {
//                        Text("Next")
//                    })
//                }
//                if currentPage.shouldShowEndButton {
//                    Button(action: endOnboarding, label: {
//                        Text("End")
//                    })
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity, maxHeight: 60)
//            .background(VisualEffectView(material: .popover))
        }
//        .onAppear {
//            self.currentPage = pages.first!
//        }
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
            Group {
                OnboardingPage.welcome.view()
                OnboardingPage.initKnownWords.view()
                OnboardingPage.downloadExtraDict.view()
            }
            .frame(width: 650, height: 530 - 28) // 28 is the height of title bar
            
//            OnboardingView(pages: OnboardingPage.allCases)
//                .frame(width: 650, height: 530) // 28 is the height of title bar
        }
    }
}
