//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI

struct EntryView: View {
    let toggle: () -> Void
    let deleteAllWordStaticstics: () -> Void
    
    @ObservedObject var statusData: StatusData
    
    let showCropper: () -> Void
    let closeCropper: () -> Void

    @State private var showingDeleteAlert = false
    
    @State private var x: String = "0"
    @State private var y: String = "50"
    @State private var w: String = "700"
    @State private var d: String = "400"
    
    @State private var interval: String = "2"

    fileprivate func image() -> Image {
        if statusData.isPlaying {
            return Image(systemName: "stop.fill")
        } else {
            return Image(systemName: "play.fill")
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "ellipsis")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            image()
                .onTapGesture {
                    toggle()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
}

func emptyFunc() -> Void {
    
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(
            toggle: emptyFunc,
            deleteAllWordStaticstics: emptyFunc,
            statusData: StatusData(),
            showCropper: emptyFunc,
            closeCropper: emptyFunc
        )
    }
}
            
