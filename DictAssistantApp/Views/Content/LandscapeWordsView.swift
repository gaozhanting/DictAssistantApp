//
//  LandscapeWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct LandscapeWordsView: View {
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault
    
    var body: some View {
        switch LandscapeStyle(rawValue: landscapeStyle)! {
        case .normal:
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    WordsView()
                    
                    VStack { Spacer() }
                }
                .paddingAndBackground()
            }
        case .centered:
            VStack {
                HStack(alignment: .top) {
                    WordsView()
                }
                
                Spacer()
            }
            .paddingAndBackground()
        }
    }
}
