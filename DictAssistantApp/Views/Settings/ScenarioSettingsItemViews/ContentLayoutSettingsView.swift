//
//  ContentLayoutSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI

struct ContentLayoutStyleSettingsView: View {
    @AppStorage(ContentLayoutKey) var contentLayout: Int = ContentLayout.portrait.rawValue

    @AppStorage(PortraitCornerKey) var portraitCorner: Int = PortraitCorner.top.rawValue
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 160.0
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Picker("Content Layout:", selection: $contentLayout) {
                        Text("portrait").tag(ContentLayout.portrait.rawValue)
                        Text("landscape").tag(ContentLayout.landscape.rawValue)
                    }
                    .frame(width: 230)
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                    
                    switch ContentLayout(rawValue: contentLayout)! {
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
                
                switch ContentLayout(rawValue: contentLayout)! {
                case .portrait:
                    HStack {
                        Spacer()
                        Text("max height per entry:")
                        TextField("", value: $portraitMaxHeight, formatter: tfDecimalFormatter).frame(width: tfWidth)
                    }
                case .landscape:
                    HStack {
                        Spacer()
                        Text("max width per entry:")
                        TextField("", value: $landscapeMaxWidth, formatter: tfDecimalFormatter).frame(width: tfWidth)
                    }
                }
            }
        }
    }
}
