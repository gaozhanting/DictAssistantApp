//
//  ContentSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI

struct ContentStyleSettingView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: Int = ContentStyle.portrait.rawValue

    @AppStorage(PortraitCornerKey) private var portraitCorner: Int = PortraitCorner.topTrailing.rawValue
    @AppStorage(LandscapeStyleKey) private var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 160.0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Content Style:", selection: $contentStyle) {
                    Text("portrait").tag(ContentStyle.portrait.rawValue)
                    Text("landscape").tag(ContentStyle.landscape.rawValue)
                }
                .frame(width: 210)
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
                switch ContentStyle(rawValue: contentStyle)! {
                case .portrait:
                    Picker("corner", selection: $portraitCorner) {
                        Text("topTrailing").tag(PortraitCorner.topTrailing.rawValue)
                        Text("topLeading").tag(PortraitCorner.topLeading.rawValue)
                        Text("bottom").tag(PortraitCorner.bottom.rawValue)
                        Text("top").tag(PortraitCorner.top.rawValue)
                    }
                    .frame(width: 180)
                    .pickerStyle(MenuPickerStyle())
                case .landscape:
                    Picker("style:", selection: $landscapeStyle) {
                        Text("normal").tag(LandscapeStyle.normal.rawValue)
                        Text("auto scrolling").tag(LandscapeStyle.autoScrolling.rawValue)
                        Text("centered").tag(LandscapeStyle.centered.rawValue)
                    }
                    .frame(width: 180)
                    .pickerStyle(MenuPickerStyle())
                }
            }

            switch ContentStyle(rawValue: contentStyle)! {
            case .portrait:
                HStack {
                    Text("Max height for one entry:")
                    TextField("", value: $portraitMaxHeight, formatter: tfDecimalFormatter).frame(width: tfWidth)
                }
            case .landscape:
                HStack {
                    Text("Max width for one entry:")
                    TextField("", value: $landscapeMaxWidth, formatter: tfDecimalFormatter).frame(width: tfWidth)
                }
            }
        }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("If the content is empty when you did run playing, what you can do?\n1. Check if there indeed has some English text in cropper area \n2. Try to turn down the Minimum Text Height \n3. Try to use Text Recognition Level accurate level \n4. Check if the words in the cropper screen are not all in your known words list \n5. Make sure the Use Entry Mode is not selected to only when you have no custom entries, which will ignore builtIn dictionary and Apple Dictionary \n6. Make sure you have already built a dictionary successfully, or make sure you did selected a valid dictionary in your Apple Dictionary Preferences if you select to use Apple Dictionary \n7. Replay (when sometimes you switch screens) \n\nHere are some tips for you:\n1. When you changed the Apple Dictionary Preferences, you need to restart this App(not restart the Apple Dictionary App) in order to take effect.\n2. In the content, you can right click (or command click) the word, and there are commands for quick add/remove to known. Remove From Known will only be available when you toggle Show Current Known Words on.\n3. Some hotkeys: Option Click the word will add or remove to known; Command Click the word will speak the word using system speech voice; Shift Click the word will open the Apple Dictionary App of the word.")
            .font(.callout)
            .padding()
            .frame(width: 520)
    }
}

//struct ContentSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoView()
//        //        .environment(\.locale, .init(identifier: "zh-Hans"))
//            .environment(\.locale, .init(identifier: "en"))
//    }
//}
