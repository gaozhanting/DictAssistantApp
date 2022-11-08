//
//  HighlightSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct HighlightSettingsView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    
    var body: some View {
        VStack(alignment: .leading) {
            Form { // Form makes it has an auto padding here
                HStack {
                    Group {
                        Picker("Highlight:", selection: $highlightMode) {
                            Text("bordered").tag(HighlightMode.bordered.rawValue)
                            Text("rectangle").tag(HighlightMode.rectangle.rawValue)
                            Text("underscored").tag(HighlightMode.underscored.rawValue)
                            Text("disabled").tag(HighlightMode.disabled.rawValue)
                        }
                        .frame(width: 200)
                        .pickerStyle(MenuPickerStyle())
                        
                        MiniInfoView {
                            HighlightInfoView()
                        }
                    }
                    
                    Spacer()
                }
            }
            
            switch HighlightMode(rawValue: highlightMode)! {
            case .bordered:
                BorderedOptionsView()
            case .rectangle:
                RectangleOptionsView()
            case .underscored:
                VStack(alignment: .leading) {
                    UnderscoredOptionsView()
                    UnderscoredIndexOptionsView()
                }
            case .disabled:
                EmptyView()
            }
        }
    }
}

struct HighlightInfoView: View {
    var body: some View {
        Text("Highlights are drawn on the cropper window. It must be on the front most of the screen, otherwise it is covered and invisible. \n\nHighlight color should have some opacity level, otherwise it will make the text below covered and invisible.")
            .infoStyle()
    }
}

struct HighlightUnderscoredView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    
    var body: some View {
        switch HighlightMode(rawValue: highlightMode)! {
        case .underscored:
            Group {
                Divider()
                HighlightUnderscoredOptionsView()
                HighlightUnderscoredIndexOptionsView()
            }
        default:
            EmptyView()
        }
    }
}

private struct HighlightUnderscoredOptionsView: View {
    @AppStorage(HLUnderscoredColorKey) var hlUnderscoredColor: Data = colorToData(NSColor.red)!
        
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(hlUnderscoredColor)!) },
            set: { newValue in
                hlUnderscoredColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        hlUnderscoredColor = colorToData(NSColor.red)!
    }
    
    var body: some View {
        HStack {
            Text("Highlight underscored line:")
            Spacer()
            ColorPicker("color:", selection: binding)
            Spacer()
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

struct UnderscoredOptionsView: View {
    @AppStorage(HLUnderscoredSizeKey) var hlUnderscoredSize: Int = HLUnderscoredSizeDefault

    var body: some View {
        Picker("Size:", selection: $hlUnderscoredSize) {
            Text("light").tag(HLUnderscoredSize.light.rawValue)
            Text("regular").tag(HLUnderscoredSize.regular.rawValue)
            Text("bold").tag(HLUnderscoredSize.bold.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 150)
    }
}

private struct HighlightUnderscoredIndexOptionsView: View {
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
            Text("Highlight underscored index:")
            
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

private struct UnderscoredIndexOptionsView: View {
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
                Text("Underscored index:")
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
    @AppStorage(HLBorderedStyleKey) var hLBorderedStyle: Int = HLBorderedStyleDefault
    
    var body: some View {
        Picker("Style:", selection: $hLBorderedStyle) {
            Text("light").tag(HLBorderedStyle.light.rawValue)
            Text("regular").tag(HLBorderedStyle.regular.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 150)
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
            ColorPicker("Color:", selection: binding)
            
            Spacer()
            
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

struct HighlightSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HighlightInfoView()
        }
    }
}
