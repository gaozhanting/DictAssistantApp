//
//  RecordingSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Preferences

struct RecordingSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Cropper Style:", comment: "")) {
                CropperStyleSettingView()
            }
            Preferences.Section(title: NSLocalizedString("Highlight:", comment: "")) {
                GroupBox {
                    VStack {
                        HighlightColorPicker()
                    }
                    .frame(width: 160)
                }
            }
            Preferences.Section(title: NSLocalizedString("Cropper Scheme:", comment: "")) {
                CloseCropperWhenNotPlayingToggle()
            }
            Preferences.Section(title: NSLocalizedString("Maximum Frame Rate:", comment: "")) {
                MaximumFrameRateSetting()
            }
        }
    }
}

private struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) private var cropperStyle: Int = CropperStyle.empty.rawValue

    var body: some View {
        Picker("", selection: $cropperStyle) {
            Text("leadingBorder").tag(CropperStyle.leadingBorder.rawValue)
            Text("trailingBorder").tag(CropperStyle.trailingBorder.rawValue)
            Text("rectangle").tag(CropperStyle.rectangle.rawValue)
            Text("strokeBorder").tag(CropperStyle.strokeBorder.rawValue)
            Text("empty").tag(CropperStyle.empty.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
    }
}

private struct HighlightColorPicker: View {
    @AppStorage(HighlightColorKey) private var highlightColor: Data = colorToData(NSColor.red.withAlphaComponent(0.1))!
    
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(highlightColor)!) },
            set: { newValue in
                highlightColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var body: some View {
        ColorPicker("Color:", selection: binding)
    }
}

private struct CloseCropperWhenNotPlayingToggle: View {
    @AppStorage(IsCloseCropperWhenNotPlayingKey) var isCloseCropperWhenNotPlaying: Bool = true
    
    var body: some View {
        Toggle(isOn: $isCloseCropperWhenNotPlaying, label: {
            Text("close cropper when not playing")
        })
            .toggleStyle(CheckboxToggleStyle())
    }
}

private struct MaximumFrameRateSetting: View {
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    
    var body: some View {
        HStack {
            TextField("", value: $maximumFrameRate, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 4
                formatter.maximum = 30
                return formatter
            }())
            .frame(width: 46)
            
            Button("Use default") {
                maximumFrameRate = 4
            }
            
            MiniInfoView(arrowEdge: Edge.trailing) {
                MaximumFrameRateInfoPopoverView()
            }
        }
    }
}

private struct MaximumFrameRateInfoPopoverView: View {
    var body: some View {
        Text("Set the maximum frame rate of the screen capture recording, default is 4fps which is a decent value for normal usage. \nThe higher the value, the more swift the App react to the cropper screen content changing, but the more CPU it consumes. 4 to 30 is all OK. \nNotice, if you need to set the text recognition level accurate at the same time, you need to set a lower value, for example 4. Because when set as a higher value, it maybe get stuck because it just can't do so much heavy lifting in such a little time.")
            .infoStyle()
    }
}

struct RecordingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecordingSettingsView()
            MaximumFrameRateInfoPopoverView()
        }
        .environmentObject(statusData)
//        .environment(\.locale, .init(identifier: "en"))
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
