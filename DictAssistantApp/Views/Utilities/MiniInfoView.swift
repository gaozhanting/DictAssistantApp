//
//  MiniInfoView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/11/21.
//

import SwiftUI

struct MiniInfoView<Content: View>: View {
    let arrowEdge: Edge
    let content: Content
    
    init(arrowEdge: Edge = .top, @ViewBuilder content: () -> Content) {
        self.arrowEdge = arrowEdge
        self.content = content()
    }
    
    @State private var isShowingPopover = false
    
    var body: some View {
        Button(action: { isShowingPopover = true }, label: {
            Image(systemName: "info.circle")
                .font(.footnote)
        })
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $isShowingPopover, arrowEdge: arrowEdge) {
            content
        }
    }
}

private struct Info: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding()
            .frame(width: 300)
    }
}

extension View {
    func infoStyle() -> some View {
        modifier(Info())
    }
}

//struct MiniInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        MiniInfoView()
//    }
//}
