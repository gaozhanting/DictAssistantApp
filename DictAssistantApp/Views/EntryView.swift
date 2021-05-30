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
    
    let toggleCropper: () -> Void

    @State private var showingDeleteAlert = false
    
    @State private var x: String = "0"
    @State private var y: String = "50"
    @State private var w: String = "700"
    @State private var d: String = "400"
    
    @State private var interval: String = "2"

    var playingImage: Image {
        if statusData.isPlaying {
            return Image(systemName: "stop.fill")
        } else {
            return Image(systemName: "play.fill")
        }
    }

    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 35, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Image(systemName: "rectangle.dashed.badge.record")
                    .font(.system(size: 35, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        toggleCropper()
                    }

                playingImage
                    .font(.system(size: 35, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        toggle()
                    }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.top)
        }
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
            toggleCropper: emptyFunc
        ).frame(width: 300, height: 30)
    }
}
            
