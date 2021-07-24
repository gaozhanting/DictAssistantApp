//
//  AppearanceSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import SwiftUI
import Preferences

struct AppearanceSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "Cropper Style:") {
                CropperStyleSettingView()
            }
            Preferences.Section(title: "Content Style:") {
                ContentStyleSettingView()
            }
            Preferences.Section(title: "Landscape Word Color:") {
                LandscapeWordColorSettingView()
            }
            Preferences.Section(title: "Portrait Word Color:") {
                PortraitWordColorSettingView()
            }
        }
    }
}

enum CropperStyle: Int {
    case closed = 0
    case rectangle = 1
}

fileprivate struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) private var cropperStyle: CropperStyle = .closed
    
    var body: some View {
        Picker("", selection: $cropperStyle) {
            Text("closed").tag(CropperStyle.closed)
            Text("rectangle").tag(CropperStyle.rectangle)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: 200)
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
        Picker("", selection: $contentStyle) {
            Text("portrait normal").tag(ContentStyle.portraitNormal)
            Text("portrait mini").tag(ContentStyle.portraitMini)
            Text("landscape normal").tag(ContentStyle.landscapeNormal)
            Text("landscape mini").tag(ContentStyle.landscapeMini)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: 200)
    }
}

fileprivate struct LandscapeWordColorSettingView: View {
    @State private var bgColor =
        Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)

    var body: some View {
        ColorPicker("", selection: $bgColor)
    }
}

fileprivate struct PortraitWordColorSettingView: View {
    @State private var bgColor =
        Color(.sRGB, red: 0.18, green: 0.9, blue: 0.2)

    var body: some View {
        ColorPicker("", selection: $bgColor)
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsView()
            .frame(width: 650, height: 500)
    }
}
