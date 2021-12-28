//
//  HighlightSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct HighlightSettingsView: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    @AppStorage(IsAlwaysRefreshHighlightKey) var isAlwaysRefreshHighlight: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Form { // Form makes it has an auto padding here
                HStack {
                    Group {
                        Picker("Highlight:", selection: $highlightMode) {
                            Text("Dotted").tag(HighlightMode.dotted.rawValue)
                            Text("Rectangle").tag(HighlightMode.rectangle.rawValue)
                            Text("Disabled").tag(HighlightMode.disabled.rawValue)
                        }
                        .frame(width: 200)
                        .pickerStyle(MenuPickerStyle())
                        
                        MiniInfoView {
                            HighlightInfoView()
                        }
                    }
                    
                    Spacer()
                    
                    Group {
                        Toggle(isOn: $isAlwaysRefreshHighlight, label: {
                            Text("Is always refresh highlight")
                        })
                            .disabled(HighlightMode(rawValue: highlightMode)! == .disabled)
                        
                        MiniInfoView {
                            IsAlwaysRefreshHighlightInfoView()
                        }
                    }
                }
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

struct HighlightInfoView: View {
    var body: some View {
        Text("Highlight are subtle in the App, that is because it is drawn on the cropper window which makes the screen recording cropper area messy, it is overlapped, it may cause blink. \nThe highlight will be hidden when the cropper window is covered by some other front window, you should make it the front most when enable highlight. \n\nI recommend using highlight rectangle when reading stream captions, the color should have some dark level and opacity level which somehow is more subtle because it is should be balanced between your eyes and the reading scenario which is watching by AI, otherwise it will cause blink. By the way, recognition accurate level is more tolerant with the color than the fast level. \nI recommend using highlight dotted when reading because it is less subtle, but the index feature is more subtle which is better used in reading books scenario, in that case, App snapshot is more useful than normal playing, and there is no blink with snapshot.\n\nAnyhow, you are free. Highlight is subtle, but it is still useful.")
            .infoStyle()
    }
}

struct IsAlwaysRefreshHighlightInfoView: View {
    var body: some View {
        Text("If you check this option, it will continually refresh highlight even when the recognized text is the same but the cropper screen area differs little from last frame, until the frames are the same. This will make the highlight always synced with the text whensoever, but the costs are consuming more CPU and increasing blink odds. \nIf you uncheck this option, highlight sometimes may not be synced with the text, in some cases when the text is the same but the cropper screen area trembled some little position. \n\nI recommend always uncheck it. It is another subtle things.")
            .infoStyle()
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
                Text("Dotted Index:")
                Spacer()
                
                Toggle(isOn: $isShowIndex, label: {
                    Text("Show Index")
                })
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

struct HighlightSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HighlightInfoView()
            IsAlwaysRefreshHighlightInfoView()
        }
    }
}
