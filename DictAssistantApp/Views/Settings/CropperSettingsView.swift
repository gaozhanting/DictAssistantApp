//
//  CropperSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/17.
//

import SwiftUI
import Preferences

struct CropperSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Cropper Style:", comment: "")) {
                CropperStyleSettingView()
            }
            Preferences.Section(title: NSLocalizedString("Cropper Scheme:", comment: "")) {
                CloseCropperWhenNotPlayingToggle()
            }
            Preferences.Section(title: NSLocalizedString("Highlight Unknown:", comment: "")) {
                HighlightView()
            }
            Preferences.Section(title: NSLocalizedString("Highlight Scheme:", comment: "")) {
                HighlightSchemeView()
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
    @AppStorage(IndexColorKey) var indexColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(IndexXBasicKey) var indexXBasic: Int = IndexXBasic.trailing.rawValue
    @AppStorage(IndexXOffsetKey) var indexXOffset: Double = 6.0
    @AppStorage(IndexFontSizeKey) var indexFontSize: Double = 7.0
    @AppStorage(ContentIndexFontSizeKey) var contentIndexFontSize: Double = 13.0

    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(indexColor)!) },
            set: { newValue in
                indexColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        isShowIndex = true
        indexColor = colorToData(NSColor.labelColor)!
        indexXBasic = IndexXBasic.trailing.rawValue
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
                        Picker("X Basic:", selection: $indexXBasic) {
                            Text("leading").tag(IndexXBasic.leading.rawValue)
                            Text("center").tag(IndexXBasic.center.rawValue)
                            Text("trailing").tag(IndexXBasic.trailing.rawValue)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
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
    @AppStorage(IndexColorRKey) var indexColorR: Data = colorToData(NSColor.labelColor)!
    @AppStorage(IndexXOffsetRKey) var indexXOffsetR: Double = 5.0
    @AppStorage(IndexYOffsetRKey) var indexYOffsetR: Double = 3.0
    @AppStorage(IndexFontSizeRKey) var indexFontSizeR: Double = 7.0
    @AppStorage(ContentIndexFontSizeRKey) var contentIndexFontSizeR: Double = 13.0

    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(indexColorR)!) },
            set: { newValue in
                indexColorR = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        isShowIndexR = true
        indexColorR = colorToData(NSColor.labelColor)!
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

private struct HighlightSchemeView: View {
    @AppStorage(IsAlwaysRefreshHighlightKey) var isAlwaysRefreshHighlight: Bool = false
    var body: some View {
        Toggle(isOn: $isAlwaysRefreshHighlight, label: {
            Text("Is always refresh highlight")
        })
            .toggleStyle(CheckboxToggleStyle())
    }
}

struct CropperSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CropperSettingsView()
            .environment(\.locale, .init(identifier: "en"))
        //        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}