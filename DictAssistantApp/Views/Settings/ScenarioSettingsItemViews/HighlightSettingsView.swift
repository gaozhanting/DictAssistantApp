//
//  HighlightSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct HighlightSettingsView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightMode.dotted.rawValue
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker("Highlight:", selection: $highlightMode) {
                Text("Dotted").tag(HighlightMode.dotted.rawValue)
                Text("Rectangle").tag(HighlightMode.rectangle.rawValue)
                Text("Disabled").tag(HighlightMode.disabled.rawValue)
            }
            .frame(width: 200)
            .pickerStyle(MenuPickerStyle())
            
            switch HighlightMode(rawValue: highlightMode)! {
            case .dotted:
                VStack(alignment: .leading) {
                    DottedOptionsView()
                    DottedIndexOptionsView()
                }
            case .rectangle:
                RectangleOptionsView()
            case .disabled:
                EmptyView()
            }
        }
    }
}

let tfWidth: CGFloat = 46
let tfDecimalFormatter: NumberFormatter = {
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
    
    var row1: some View {
        HStack {
            Text("downward:")
            TextField("", value: $strokeDownwardOffset, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Spacer()
            Text("line width:")
            TextField("", value: $strokeLineWidth, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
   
            Spacer()
            ColorPicker("color:", selection: binding)
            
        }
    }
    
    var row2: some View {
        HStack {
            Text("dash painted:")
            TextField("", value: $strokeDashPainted, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Spacer()
            
            Text("dash unpainted:")
            TextField("", value: $strokeDashUnPainted, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Spacer()
            
            Button(action: useDefault) {
                Image(systemName: "pencil.and.outline")
            }
        }
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                row1
                row2
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
    
    var row1: some View {
        HStack {
            Picker("X Basic:", selection: $indexXBasic) {
                Text("leading").tag(IndexXBasic.leading.rawValue)
                Text("center").tag(IndexXBasic.center.rawValue)
                Text("trailing").tag(IndexXBasic.trailing.rawValue)
            }
            .frame(width: 170)
            .pickerStyle(MenuPickerStyle())
            
            Spacer()
            
            Text("Padding:")
            TextField("", value: $indexPadding, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
        }
    }
    
    var row2: some View {
        HStack {
            Text("Cropper Font Size:")
            TextField("", value: $indexFontSize, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Spacer()
            
            ColorPicker("Color:", selection: indexColorBinding)
            
            Spacer()
            
            ColorPicker("BG Color:", selection: indexBgColorBinding)
        }
    }
    
    var row3: some View {
        HStack {
            Text("Content Font Size:")
            TextField("", value: $contentIndexFontSize, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Spacer()
            
            ColorPicker("Color:", selection: contentIndexColorBinding)
            
            Spacer()
            
            Button(action: useDefault) {
                Image(systemName: "pencil.and.outline")
            }
        }
    }
    
    var body: some View {
        Group {
            Toggle(isOn: $isShowIndex, label: {
                Text("Show Index")
            })
                .toggleStyle(CheckboxToggleStyle())
            
            if isShowIndex {
                GroupBox {
                    VStack(alignment: .leading) {
                        if isShowIndex {
                            VStack {
                                row1
                                row2
                                row3
                            }
                        }
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
            HStack {
                ColorPicker("", selection: binding)
                    .labelsHidden()
                
                Spacer()
                
                Text("v padding:")
                TextField("", value: $rectangleVerticalPadding, formatter: tfDecimalFormatter)
                    .frame(width: tfWidth)
                
                Spacer()
                
                Text("h padding:")
                TextField("", value: $rectangleHorizontalPadding, formatter: tfDecimalFormatter)
                    .frame(width: tfWidth)
                
                Spacer()
                
                Button(action: useDefault) {
                    Image(systemName: "pencil.and.outline")
                }
            }
        }
    }
}

struct HighlightSchemeView: View {
    @AppStorage(IsAlwaysRefreshHighlightKey) var isAlwaysRefreshHighlight: Bool = false
    
    var body: some View {
        Toggle(isOn: $isAlwaysRefreshHighlight, label: {
            Text("Is always refresh highlight")
        })
    }
}

//struct HighlightSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        HighlightSettingsView()
//    }
//}
