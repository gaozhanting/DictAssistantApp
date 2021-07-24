//
//  AppearanceSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import SwiftUI

struct AppearanceSettingsView: View {
    var body: some View {
        VStack(alignment: .trailing) {
            CropperStyleSettingView()
            ContentStyleSettingView()
            Group {
                LandscapeWordColorSettingView()
                PortraitWordColorSettingView()
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum CropperStyle: Int {
    case closed = 0
    case rectangle = 1
}

fileprivate struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) private var cropperStyle: CropperStyle = .closed
    
    var body: some View {
        Picker("Cropper style: ", selection: $cropperStyle) {
            Text("closed").tag(CropperStyle.closed)
            Text("rectangle").tag(CropperStyle.rectangle)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: 400)
    }
}

enum ContentStyle: Int {
    case portraitNormal = 0
    case portraitMini = 1
    case landscapeNormal = 2
    case landscapeMini = 3
}

fileprivate struct ContentStyleSettingView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portraitNormal
    
    var body: some View {
        Picker("Content style: ", selection: $contentStyle) {
            Text("portrait normal").tag(ContentStyle.portraitNormal)
            Text("portrait mini").tag(ContentStyle.portraitMini)
            Text("landscape normal").tag(ContentStyle.landscapeNormal)
            Text("landscape mini").tag(ContentStyle.landscapeMini)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: 400)
    }
}

fileprivate struct LandscapeWordColorSettingView: View {
    @State private var bgColor =
        Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)

    var body: some View {
        HStack {
            Spacer()
            ColorPicker("Landscape word color: ", selection: $bgColor)
        }
    }
}

fileprivate struct PortraitWordColorSettingView: View {
    @State private var bgColor =
        Color(.sRGB, red: 0.18, green: 0.9, blue: 0.2)

    var body: some View {
        HStack {
            Spacer()
            ColorPicker("Portrait word color: ", selection: $bgColor)
        }
    }
}



struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsView()
    }
}
