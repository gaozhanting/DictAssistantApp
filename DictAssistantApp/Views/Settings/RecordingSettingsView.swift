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
            Preferences.Section(title: NSLocalizedString("Maximum Frame Rate:", comment: "")) {
                MaximumFrameRateSetting()
            }
        }
    }
}

enum CropperStyle: Int, Codable {
    case closed = 0
    case rectangle = 1
    case leadingBorder = 2
    case trailingBorder = 3
}

fileprivate struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) private var cropperStyle: CropperStyle = .closed

    var body: some View {
        Picker("", selection: $cropperStyle) {
            Text("leadingBorder").tag(CropperStyle.leadingBorder)
            Text("trailingBorder").tag(CropperStyle.trailingBorder)
            Text("rectangle").tag(CropperStyle.rectangle)
            Text("closed").tag(CropperStyle.closed)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
    }
}

fileprivate struct MaximumFrameRateSetting: View {
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    @EnvironmentObject var statusData: StatusData
    
    var body: some View {
        HStack {
            TextField("", value: $maximumFrameRate, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 1
                formatter.maximum = 30
                return formatter
            }())
            .frame(width: 46)
            .disabled(statusData.isPlaying)
            
            Button("Use default") {
                maximumFrameRate = 4
            }
            .disabled(statusData.isPlaying)
            
            MiniInfoView(arrowEdge: Edge.trailing) {
                MaximumFrameRateInfoPopoverView()
            }
        }
    }
}

fileprivate struct MaximumFrameRateInfoPopoverView: View {
    var body: some View {
        Text("Set the maximum frame rate of the screen capture recording, default is 4fps which is a decent value for normal usage. \nThe higher the value, the more swift the APP react to the cropper screen content changing, but the more CPU it consumes. 1 to 30 is all OK.\nThe animation duration normally is 1/number. \nNotice, if you set a number less than 4, that will still use 4 as the fps, but the animation duration is still 1/number. \nNotice, if you need to set the text recognition level accurate at the same time, you need to set a lower value, for example 4. Because when set as a higher value, it maybe get stuck because it just can't do so much heavy lifting in such a little time.")
            .font(.subheadline)
            .padding()
            .frame(width: 300, height: 250)
    }
}

struct RecordingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecordingSettingsView()
            MaximumFrameRateInfoPopoverView()
        }
    }
}
