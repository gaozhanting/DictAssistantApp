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
            Preferences.Section(title: NSLocalizedString("Cropper Scheme:", comment: "")) {
                CloseCropperWhenNotPlayingToggle()
            }
            Preferences.Section(title: NSLocalizedString("Maximum Frame Rate:", comment: "")) {
                MaximumFrameRateSetting()
            }
            Preferences.Section(title: NSLocalizedString("Highlight Unknown:", comment: "")) {
                HighlightView()
            }
        }
    }
}

private struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) private var cropperStyle: Int = CropperStyle.empty.rawValue

    var body: some View {
        Picker("", selection: $cropperStyle) {
            Text("empty").tag(CropperStyle.empty.rawValue)
            Text("rectangle").tag(CropperStyle.rectangle.rawValue)
            Text("strokeBorder").tag(CropperStyle.strokeBorder.rawValue)
            
            Text("leadingBorder").tag(CropperStyle.leadingBorder.rawValue)
            Text("trailingBorder").tag(CropperStyle.trailingBorder.rawValue)
            Text("topBorder").tag(CropperStyle.topBorder.rawValue)
            Text("bottomBorder").tag(CropperStyle.bottomBorder.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
    }
}

private struct HighlightView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightMode.dotted.rawValue
    
    var body: some View {
        VStack {
            Picker("", selection: $highlightMode) {
                Text("Dotted").tag(HighlightMode.dotted.rawValue)
                Text("Rectangle").tag(HighlightMode.rectangle.rawValue)
                Text("Disabled").tag(HighlightMode.disabled.rawValue)
            }
            .pickerStyle(MenuPickerStyle())
            .labelsHidden()
            
            switch HighlightMode(rawValue: highlightMode)! {
            case .dotted:
                GroupBox {
                    HStack(alignment: .top) {
                        DottedOptionsView()
                        DottedIndexOptionsView()
                    }
                }
            case .rectangle:
                GroupBox {
                    HStack(alignment: .top) {
                        RectangleOptionsView()
                        RectangleIndexOptionsView()
                    }
                }
            case .disabled:
                EmptyView()
            }
        }
        .frame(width: 400)
    }
}

private let tfWidth: CGFloat = 46
private let tfDecimalFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    return f
}()

private struct RectangleOptionsView: View {
    @AppStorage(HLRectangleColorKey) private var hlRectangleColor: Data = colorToData(NSColor.red.withAlphaComponent(0.15))!
    @AppStorage(RectangleVerticalPaddingKey) var rectangleVerticalPadding: Double = 2.0
    @AppStorage(RectangleHorizontalPaddingKey) var rectangleHorizontalPadding: Double = 4.0
    
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(hlRectangleColor)!) },
            set: { newValue in
                hlRectangleColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        hlRectangleColor = colorToData(NSColor.red.withAlphaComponent(0.15))!
        rectangleVerticalPadding = 2.0
        rectangleHorizontalPadding = 4.0
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    ColorPicker("color:", selection: binding)
                }
                
                HStack {
                    Spacer()
                    Text("vertical padding:")
                    TextField("", value: $rectangleVerticalPadding, formatter: tfDecimalFormatter)
                        .frame(width: tfWidth)
                }
                
                HStack {
                    Spacer()
                    Text("horizontal padding:")
                    TextField("", value: $rectangleHorizontalPadding, formatter: tfDecimalFormatter)
                        .frame(width: tfWidth)
                }
                
                HStack {
                    Spacer()
                    Button("Use Default") {
                        useDefault()
                    }
                }
            }
        }
    }
}

private struct DottedIndexOptionsView: View {
    @AppStorage(IsShowIndexKey) var isShowIndex: Bool = true
    @AppStorage(ContentIndexColorKey) var contentIndexColor: Data = colorToData(NSColor.highlightColor)!
    @AppStorage(IndexXOffsetKey) var indexXOffset: Double = 6.0
    @AppStorage(IndexFontSizeKey) var indexFontSize: Double = 7.0
    @AppStorage(ContentIndexFontSizeKey) var contentIndexFontSize: Double = 13.0

    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(contentIndexColor)!) },
            set: { newValue in
                contentIndexColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        isShowIndex = true
        contentIndexColor = colorToData(NSColor.highlightColor)!
        indexXOffset = 6.0
        indexFontSize = 7.0
        contentIndexFontSize = 13.0
    }
    
    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    Spacer()
                    Toggle(isOn: $isShowIndex, label: {
                        Text("Show Index")
                    })
                        .toggleStyle(SwitchToggleStyle())
                }
                
                if isShowIndex {
                    HStack {
                        Spacer()
                        Text("X Offset:")
                        TextField("", value: $indexXOffset, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Cropper Font Size:")
                        TextField("", value: $indexFontSize, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Content Font Size:")
                        TextField("", value: $contentIndexFontSize, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                    }
                    
                    HStack {
                        Spacer()
                        ColorPicker("color:", selection: binding)
                    }
                    
                    HStack {
                        Spacer()
                        Button("Use Default") {
                            useDefault()
                        }
                    }
                }
            }
        }
    }
}

private struct RectangleIndexOptionsView: View {
    @AppStorage(IsShowIndexRKey) var isShowIndexR: Bool = true
    @AppStorage(ContentIndexColorRKey) var contentIndexColorR: Data = colorToData(NSColor.highlightColor)!
    @AppStorage(IndexXOffsetRKey) var indexXOffsetR: Double = 5.0
    @AppStorage(IndexYOffsetRKey) var indexYOffsetR: Double = 3.0
    @AppStorage(IndexFontSizeRKey) var indexFontSizeR: Double = 7.0
    @AppStorage(ContentIndexFontSizeRKey) var contentIndexFontSizeR: Double = 13.0

    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(contentIndexColorR)!) },
            set: { newValue in
                contentIndexColorR = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        isShowIndexR = true
        contentIndexColorR = colorToData(NSColor.highlightColor)!
        indexXOffsetR = 6.0
        indexFontSizeR = 7.0
        contentIndexFontSizeR = 13.0
    }
    
    
    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    Spacer()
                    Toggle(isOn: $isShowIndexR, label: {
                        Text("Show Index")
                    })
                        .toggleStyle(SwitchToggleStyle())
                }
                
                if isShowIndexR {
                    HStack {
                        Spacer()
                        Text("X Offset:")
                        TextField("", value: $indexXOffsetR, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Y Offset:")
                        TextField("", value: $indexYOffsetR, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Cropper Font Size:")
                        TextField("", value: $indexFontSizeR, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Content Font Size:")
                        TextField("", value: $contentIndexFontSizeR, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                    }
                    
                    HStack {
                        Spacer()
                        ColorPicker("color:", selection: binding)
                    }
                    
                    HStack {
                        Spacer()
                        Button("Use Default") {
                            useDefault()
                        }
                    }
                }
            }
        }
    }
}

private struct DottedOptionsView: View {
    @AppStorage(StrokeDownwardOffsetKey) var strokeDownwardOffset: Double = 5.0
    @AppStorage(HLDottedColorKey) private var hlDottedColor: Data = colorToData(NSColor.red)!
    @AppStorage(StrokeLineWidthKey) var strokeLineWidth: Double = 3.0
    @AppStorage(StrokeDashPaintedKey) var strokeDashPainted: Double = 1.6
    @AppStorage(StrokeDashUnPaintedKey) var strokeDashUnPainted: Double = 3.0
    
    func useDefault() {
        hlDottedColor = colorToData(NSColor.red)!
        strokeDownwardOffset = 4.0
        strokeLineWidth = 3.0
        strokeDashPainted = 1.0
        strokeDashUnPainted = 5.0
    }

    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(hlDottedColor)!) },
            set: { newValue in
                hlDottedColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("downward offset:")
                    TextField("", value: $strokeDownwardOffset, formatter: tfDecimalFormatter)
                        .frame(width: tfWidth)
                }
                
                HStack {
                    Spacer()
                    ColorPicker("color:", selection: binding)
                }
                
                HStack {
                    Spacer()
                    Text("line width:")
                    TextField("", value: $strokeLineWidth, formatter: tfDecimalFormatter)
                        .frame(width: tfWidth)
                }
                
                HStack {
                    Spacer()
                    Text("dash painted:")
                    TextField("", value: $strokeDashPainted, formatter: tfDecimalFormatter)
                        .frame(width: tfWidth)
                }
                
                HStack {
                    Spacer()
                    Text("dash unpainted:")
                    TextField("", value: $strokeDashUnPainted, formatter: tfDecimalFormatter)
                        .frame(width: tfWidth)
                }
                
                HStack {
                    Spacer()
                    Button("Use Default") {
                        useDefault()
                    }
                }
            }
        }
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
        .environment(\.locale, .init(identifier: "en"))
//        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
