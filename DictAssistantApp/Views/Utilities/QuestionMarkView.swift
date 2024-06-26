//
//  QuestionMarkView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/11/21.
//

import SwiftUI

struct QuestionMarkView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State var isShowingPopover: Bool = false

    var body: some View {
        Button(action: { isShowingPopover = true }, label: {
            Image(systemName: "questionmark").font(.body)
        })
            .clipShape(Circle())
            .padding()
            .shadow(color: .primary, radius: 3)
            .popover(isPresented: $isShowingPopover, arrowEdge: .leading, content: {
                content
            })
    }
}

//struct QuestionMarkView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuestionMarkView()
//    }
//}
