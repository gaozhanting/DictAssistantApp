//
//  OnboardingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/15.
//

import SwiftUI

enum OnboardingPage: CaseIterable {
    case welcome
    case newFeature
    case permissions
    case sales
    
    var shouldShowNextButton: Bool {
        !(self == .sales)
    }
    
    var shouldShowEndButton: Bool {
        self == .sales
    }
    
    @ViewBuilder
    func view(/*action: @escaping () -> Void*/) -> some View {
        switch self {
        case .welcome:
            VStack {
                Text("Welcome")
                Text("Detailed")
            }
        case .newFeature:
            Text("See this new feature!")
        case .permissions:
            HStack {
                Text("We need permissions")
                
//                // This button should only be enabled once permissions are set:
//                Button(action: action, label: {
//                    Text("Continue")
//                })
            }
        case .sales:
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
                    page.view()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(AnyTransition.asymmetric(
                                        insertion: .move(edge: .trailing),
                                        removal: .move(edge: .leading))
                        )
                        .animation(.default)
                }
            }
            
            HStack {
                Spacer()
                if currentPage.shouldShowNextButton {
                    Button(action: showNextPage, label: {
                        Text("Next")
                    })
                }
                if currentPage.shouldShowEndButton {
                    Button(action: endOnboarding, label: {
                        Text("End")
                    })
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(VisualEffectView(material: .popover))
        }
        .onAppear {
            self.currentPage = pages.first!
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
            Group {
                OnboardingPage.welcome.view()
                OnboardingPage.newFeature.view()
            }
            .frame(width: 650, height: 530 - 28) // 28 is the height of title bar
            
            OnboardingView(pages: OnboardingPage.allCases)
                .frame(width: 650, height: 530) // 28 is the height of title bar
        }
    }
}
