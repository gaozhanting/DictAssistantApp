//
//  HighlightSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct HighlightSettingsView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    
    @AppStorage(CropperHasShadowKey) var cropperHasShadow: Bool = CropperHasShadowDefault
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Highlight:", selection: $highlightMode) {
                    Text("Bordered").tag(HighlightMode.bordered.rawValue)
                    Text("Rectangle").tag(HighlightMode.rectangle.rawValue)
                    Text("Dotted").tag(HighlightMode.dotted.rawValue)
                    Text("Disabled").tag(HighlightMode.disabled.rawValue)
                }
                .frame(width: 200)
                .pickerStyle(MenuPickerStyle())
                
                MiniInfoView {
                    HighlightInfoView()
                }
                
                Spacer()
                
                Toggle(isOn: $cropperHasShadow) {
                    Text("Cropper has shadow")
                }
                .toggleStyle(CheckboxToggleStyle())
                
                MiniInfoView {
                    CropperHasShadowInfo()
                }
            }
            .padding(.top, 3)
            .padding(.bottom, 3)
            
            switch HighlightMode(rawValue: highlightMode)! {
            case .bordered:
                BorderedOptionsView()
            case .rectangle:
                RectangleOptionsView()
            case .dotted:
                VStack(alignment: .leading) {
                    DottedOptionsView()
                    DottedIndexOptionsView()
                }
            case .disabled:
                EmptyView()
            }
        }
    }
}

private struct CropperHasShadowInfo: View {
    var body: some View {
        Text("Set this true when you like the window shadow effect. It will persistently rerender the cropper window shadow which will make the highlight shadow always synchronized, thus consumes CPU.")
            .infoStyle()
    }
}

struct HighlightInfoView: View {
    var body: some View {
        Text("Highlights are drawn on the cropper window. It must be on the front most of the screen, otherwise it is covered and invisible.")
            .infoStyle()
    }
}

struct HighlightDottedView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    
    var body: some View {
        switch HighlightMode(rawValue: highlightMode)! {
        case .dotted:
            Group {
                Divider()
                HighlightDottedOptionsView()
                HighlightDottedIndexOptionsView()
            }
        default:
            EmptyView()
        }
    }
}

private struct HighlightDottedOptionsView: View {
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
            Text("Highlight dotted line:")
            Spacer()
            ColorPicker("color:", selection: binding)
            Spacer()
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

struct DottedOptionsView: View {
    @AppStorage(StrokeDownwardOffsetKey) var strokeDownwardOffset: Double = StrokeDownwardOffsetDefault
    @AppStorage(StrokeLineWidthKey) var strokeLineWidth: Double = 1.6
    @AppStorage(StrokeDashPaintedKey) var strokeDashPainted: Double = 1.0
    @AppStorage(StrokeDashUnPaintedKey) var strokeDashUnPainted: Double = 3.0
    
    func useDefault() {
        strokeDownwardOffset = StrokeDownwardOffsetDefault
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
            Text("Dotted line:")
            GroupBox {
                HStack {
                    r1
                    r2
                }
            }
        }
    }
}

private struct HighlightDottedIndexOptionsView: View {
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
            Text("Highlight dotted index:")
            
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        Picker("X basic:", selection: $indexXBasic) {
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
                        ColorPicker("Background:", selection: indexBgColorBinding)
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
    @AppStorage(IndexPaddingKey) var indexPadding: Double = 1.5
    
    func useDefault() {
        isShowIndex = false
        indexFontSize = 5
        indexPadding = 1.5
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Dotted index:")
                Spacer()
                
                Toggle(isOn: $isShowIndex) {
                    Text("Show index")
                }
                .toggleStyle(CheckboxToggleStyle())
            }
            
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
            .disabled(!isShowIndex)
        }
    }
}

private struct BorderedOptionsView: View {
    @AppStorage(HLBorderedStyleKey) var hlBorderedStyle: Int = HLBorderedStyleDefault
    @AppStorage(HLBorderedColorKey) var hlBorderedColor: Data = HLBorderedColorDefault
    
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(hlBorderedColor)!) },
            set: { newValue in
                hlBorderedColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        hlBorderedStyle = HLBorderedStyleDefault
        hlBorderedColor = HLBorderedColorDefault
    }
    
    var body: some View {
        HStack {
            Picker("Style:", selection: $hlBorderedStyle) {
                Text("light").tag(HLBorderedStyle.light.rawValue)
                Text("regular").tag(HLBorderedStyle.regular.rawValue)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
            
            Spacer()
            
            ColorPicker("Color:", selection: binding)
            
            Spacer()
            
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

private struct RectangleOptionsView: View {
    @AppStorage(HLRectangleColorKey) var hlRectangleColor: Data = HLRectangleColorDefault
    
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(hlRectangleColor)!) },
            set: { newValue in
                hlRectangleColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        hlRectangleColor = HLRectangleColorDefault
    }
    
    var body: some View {
        HStack {
            Group {
                ColorPicker("Color:", selection: binding)
                
                MiniInfoView {
                    HLRectangleInfoView()
                }
            }
            
            Spacer()
            
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

struct HLRectangleInfoView: View {
    var body: some View {
        Text("Rectangle highlight color should have some opacity level, otherwise it will make the text below covered and invisible.")
            .infoStyle()
    }
}

struct HighlightSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HighlightInfoView()
            HLRectangleInfoView()
            
            CropperHasShadowInfo()
        }
    }
}
