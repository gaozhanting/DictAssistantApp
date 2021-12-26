//
//  HighlightSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct HighlightSettingsView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightMode.dotted.rawValue
    @AppStorage(IsAlwaysRefreshHighlightKey) var isAlwaysRefreshHighlight: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Highlight:", selection: $highlightMode) {
                    Text("Dotted").tag(HighlightMode.dotted.rawValue)
                    Text("Rectangle").tag(HighlightMode.rectangle.rawValue)
                    Text("Disabled").tag(HighlightMode.disabled.rawValue)
                }
                .frame(width: 200)
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
                Toggle(isOn: $isAlwaysRefreshHighlight, label: {
                    Text("Is always refresh highlight")
                })
            }
            
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

struct HighlightDottedOptionsView: View {
    @AppStorage(HLDottedColorKey) var hlDottedColor: Data = colorToData(NSColor.red)!
        
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(hlDottedColor)!) },
            set: { newValue in
                hlDottedColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        hlDottedColor = colorToData(NSColor.red)!
    }
    
    var body: some View {
        HStack {
            Text("Highlight Dotted Line:")
            Spacer()
            ColorPicker("color:", selection: binding)
            Spacer()
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

private struct DottedOptionsView: View {
    @AppStorage(StrokeDownwardOffsetKey) var strokeDownwardOffset: Double = 5.0
    @AppStorage(StrokeLineWidthKey) var strokeLineWidth: Double = 1.6
    @AppStorage(StrokeDashPaintedKey) var strokeDashPainted: Double = 1.0
    @AppStorage(StrokeDashUnPaintedKey) var strokeDashUnPainted: Double = 3.0
    
    func useDefault() {
        strokeDownwardOffset = 4.0
        strokeLineWidth = 3.0
        strokeDashPainted = 1.0
        strokeDashUnPainted = 5.0
    }
    
    var r1: some View {
        Group {
            Text("down:")
            TextField("", value: $strokeDownwardOffset, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Spacer()
            
            Text("width:")
            TextField("", value: $strokeLineWidth, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Text("paint:")
            TextField("", value: $strokeDashPainted, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
            
            Spacer()
            
            Text("unpaint:")
            TextField("", value: $strokeDashUnPainted, formatter: tfDecimalFormatter)
                .frame(width: tfWidth)
        }
    }
    
    var r2: some View {
        Group {
            Spacer()
            
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Dotted Line:")
            GroupBox {
                HStack {
                    r1
                    r2
                }
            }
        }
    }
}

struct HighlightDottedIndexOptionsView: View {
    @AppStorage(IndexXBasicKey) var indexXBasic: Int = IndexXBasic.trailing.rawValue
    @AppStorage(IndexColorKey) var indexColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(IndexBgColorKey) var indexBgColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ContentIndexColorKey) var contentIndexColor: Data = colorToData(NSColor.systemOrange)!
    
    func useDefault() {
        indexXBasic = IndexXBasic.trailing.rawValue
        
        indexColor = colorToData(NSColor.windowBackgroundColor)!
        indexBgColor = colorToData(NSColor.labelColor)!
        
        contentIndexColor = colorToData(NSColor.systemOrange)!
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
    
    var body: some View {
        Group {
            Text("Highlight Dotted Index:")
            
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        Picker("X Basic:", selection: $indexXBasic) {
                            Text("leading").tag(IndexXBasic.leading.rawValue)
                            Text("center").tag(IndexXBasic.center.rawValue)
                            Text("trailing").tag(IndexXBasic.trailing.rawValue)
                        }
                        .frame(width: 170)
                        .pickerStyle(MenuPickerStyle())
                        
                        Spacer()
                        
                        Button(action: useDefault) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                    
                    HStack {
                        ColorPicker("Index:", selection: indexColorBinding)
                        Spacer()
                        ColorPicker("BG:", selection: indexBgColorBinding)
                        Spacer()
                        ColorPicker("Content:", selection: contentIndexColorBinding)
                    }
                }
            }
        }
    }
}

private struct DottedIndexOptionsView: View {
    @AppStorage(IsShowIndexKey) var isShowIndex: Bool = false
    @AppStorage(IndexFontSizeKey) var indexFontSize: Int = 5
    @AppStorage(IndexPaddingKey) var indexPadding: Double = 2.0
    
    func useDefault() {
        isShowIndex = false
        indexFontSize = 7
        indexPadding = 2.0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Dotted Index:")
                Spacer()
                
                Toggle(isOn: $isShowIndex, label: {
                    Text("Show Index")
                })
                    .toggleStyle(CheckboxToggleStyle())
            }
            
            if isShowIndex {
                GroupBox {
                    HStack {
                        Text("padding:")
                        TextField("", value: $indexPadding, formatter: tfDecimalFormatter)
                            .frame(width: tfWidth)
                        
                        Spacer()
                        
                        Text("font size:")
                        TextField("", value: $indexFontSize, formatter: tfIntegerFormatter)
                            .frame(width: tfWidth)
                        
                        Spacer()
                        
                        Button(action: useDefault) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                }
            }
        }
    }
}

private struct RectangleOptionsView: View {
    @AppStorage(HLRectangleColorKey) var hlRectangleColor: Data = colorToData(NSColor.red.withAlphaComponent(0.15))!
    
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
    }
    
    var body: some View {
        HStack {
            Text("Highlight Rectangle:")
            
            Spacer()
            
            ColorPicker("Color:", selection: binding)
            
            Spacer()
            
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

//struct HighlightSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        HighlightSettingsView()
//    }
//}
