//
//  HighlightSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct HighlightView: View {
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
                    }
                }
            case .disabled:
                EmptyView()
            }
        }
    }
}

private let tfWidth: CGFloat = 46
private let tfDecimalFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    return f
}()

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
                    Text("downward:")
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

private struct DottedIndexOptionsView: View {
    @AppStorage(IsShowIndexKey) var isShowIndex: Bool = true
    @AppStorage(IndexXBasicKey) var indexXBasic: Int = IndexXBasic.trailing.rawValue
    @AppStorage(IndexFontSizeKey) var indexFontSize: Double = 7.0
    @AppStorage(IndexPaddingKey) var indexPadding: Double = 2.0
    @AppStorage(IndexColorKey) var indexColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(IndexBgColorKey) var indexBgColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ContentIndexFontSizeKey) var contentIndexFontSize: Double = 13.0
    @AppStorage(ContentIndexColorKey) var contentIndexColor: Data = colorToData(NSColor.labelColor)!
    
    func useDefault() {
        isShowIndex = true
        indexXBasic = IndexXBasic.trailing.rawValue
        indexFontSize = 7.0
        indexPadding = 2.0
        indexColor = colorToData(NSColor.windowBackgroundColor)!
        indexBgColor = colorToData(NSColor.labelColor)!
        contentIndexFontSize = 13.0
        contentIndexColor = colorToData(NSColor.labelColor)!
    }
    
    var indexColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(indexColor)!) },
            set: { newValue in
                indexColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var indexBgColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(indexBgColor)!) },
            set: { newValue in
                indexBgColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var contentIndexColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(contentIndexColor)!) },
            set: { newValue in
                contentIndexColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var cropperG: some View {
        Group{
            Divider()
            
            Text("Cropper:")
            
            Picker("X Basic:", selection: $indexXBasic) {
                Text("leading").tag(IndexXBasic.leading.rawValue)
                Text("center").tag(IndexXBasic.center.rawValue)
                Text("trailing").tag(IndexXBasic.trailing.rawValue)
            }
            .pickerStyle(MenuPickerStyle())
            
            HStack {
                Spacer()
                Text("Font Size:")
                TextField("", value: $indexFontSize, formatter: tfDecimalFormatter)
                    .frame(width: tfWidth)
            }
            
            HStack {
                Spacer()
                Text("Padding:")
                TextField("", value: $indexPadding, formatter: tfDecimalFormatter)
                    .frame(width: tfWidth)
            }
            
            ColorPicker("Color:", selection: indexColorBinding)
            
            ColorPicker("BG Color:", selection: indexBgColorBinding)
        }
    }
    
    var contentG: some View {
        Group {
            Divider()
            
            Text("Content:")
            
            HStack {
                Spacer()
                Text("Font Size:")
                TextField("", value: $contentIndexFontSize, formatter: tfDecimalFormatter)
                    .frame(width: tfWidth)
            }
            
            ColorPicker("Color:", selection: contentIndexColorBinding)
            
        }
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Toggle(isOn: $isShowIndex, label: {
                        Text("Show Index")
                    })
                        .toggleStyle(SwitchToggleStyle())
                }
                
                if isShowIndex {
                    
                    cropperG
                    
                    contentG
                    
                    Divider()
                    Button("Use Default") {
                        useDefault()
                    }
                }
            }
        }
    }
}

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

struct HighlightSchemeView: View {
    @AppStorage(IsAlwaysRefreshHighlightKey) var isAlwaysRefreshHighlight: Bool = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $isAlwaysRefreshHighlight, label: {
                Text("Is always refresh highlight")
            })
                .toggleStyle(CheckboxToggleStyle())
            Spacer()
        }
    }
}
