//
//  OnboardingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/15.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack {
            Content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Controller()
        }
    }
}

fileprivate struct Content: View {
    var body: some View {
        Text("some content")
    }
}

fileprivate struct Welcome: View {
    var body: some View {
        Text("Welcome")
    }
}

fileprivate struct Controller: View {
    @Environment(\.endOnboarding) var endOnboarding
    @State private var notShow: Bool = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $notShow) {
                Text("Don't show this window again")
            }
            Spacer()
            Button("Previous") {}
//            Button("next") {}
            Button("end") {
                endOnboarding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 60)
        .background(
            VisualEffectView(material: .popover)
        )
    }
}



/*
enum OnboardingPage: CaseIterable {
    case welcome
    case newFeature
    case permissions
    case sales
    
    static let fullOnboarding = OnboardingPage.allCases
    
    var shouldShowNextButton: Bool {
        switch self {
        case .welcome, .newFeature:
            return true
        default:
            return false
        }
    }
    
    @ViewBuilder
    func view(action: @escaping () -> Void) -> some View {
        switch self {
        case .welcome:
            Text("Welcome")
        case .newFeature:
            Text("See this new feature!")
        case .permissions:
            HStack {
                Text("We need permissions")
                
                // This button should only be enabled once permissions are set:
                Button(action: action, label: {
                    Text("Continue")
                })
            }
        case .sales:
            HStack {
                Text("Become PRO for even more features")
                
                Button(action: {
                    NSApplication.shared.stopModal()
                }, label: {
                    Text("OK")
                })
            }
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
                    page.view(action: showNextPage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(AnyTransition.asymmetric(
                                        insertion: .move(edge: .trailing),
                                        removal: .move(edge: .leading))
                        )
                        .animation(.default)
                }
            }
            
            if currentPage.shouldShowNextButton {
                HStack {
                    Spacer()
                    Button(action: showNextPage, label: {
                        Text("Next")
                    })
                }
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 50, trailing: 50))
                .transition(AnyTransition.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading))
                )
                .animation(.default)
            }
        }
        .frame(width: 800, height: 600)
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
 */

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .frame(width: 650, height: 580 - 28) // 28 is the height of title bar
    }
}
