//
//  SceneSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct SceneSettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            SelectedSlotView(imageFont: .title, textFont: .callout)
            GroupBox {
                VStack(alignment: .leading) {
                    RecognitionLevelSetting()
                    MaximumFrameRateSetting()
                }
            }
            GroupBox {
                VStack(alignment: .leading) {
                    MinimumTextHeightSetting()
                    UsesLanguageCorrectionToggle()
                    IsOpenLemmaToggle()
                    IsShowToastView()
                }
            }
            GroupBox {
                FontConfigView()
                ContentMaxSettingsView()
            }
            GroupBox {
                ColorPickers()
                
                ContentHasShadowToggle()
                ContentBackgroundVisualEffect()
                ColorSchemeSetting()
            }
            ContentPaddingStyleSettingsView()
            CropperStyleSettingView()
            Divider()
            HighlightSettingsView()
        }
        .padding()
        .frame(width: panelWidth)
    }
}

struct ContentMaxSettingsView: View {
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = PortraitMaxHeightDefault
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = LandscapeMaxWidthDefault
    
    var body: some View {
        HStack {
            Text("Max height per entry:")
            TextField("", value: $portraitMaxHeight, formatter: tfDecimalFormatter).frame(width: tfWidth)
            
            Spacer()
            
            Text("Max width per entry:")
            TextField("", value: $landscapeMaxWidth, formatter: tfDecimalFormatter).frame(width: tfWidth)
        }
    }
}

private struct ColorPickers: View {
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor)!
    var colorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(wordColor)!) },
            set: { newValue in
                wordColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    var transColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(transColor)!) },
            set: { newValue in
                transColor = colorToData(NSColor(newValue))!
            }
        )
    }

    @AppStorage(BackgroundColorKey) var backgroundColor: Data = BackgroundColorDefault
    var bgColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(backgroundColor)!) },
            set: { newValue in
                backgroundColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        wordColor = colorToData(NSColor.labelColor)!
        transColor = colorToData(NSColor.secondaryLabelColor)!
        backgroundColor = BackgroundColorDefault
    }
    
    var body: some View {
        HStack {
            ColorPicker("Word:", selection: colorBinding)
            Spacer()
            ColorPicker("Trans:", selection: transColorBinding)
            Spacer()
            ColorPicker("Background:", selection: bgColorBinding)
            Spacer()
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

private struct ContentHasShadowToggle: View {
    @AppStorage(ContentHasShadowKey) var contentHasShadow: Bool = ContentHasShadowDefault
    
    var body: some View {
        HStack {
            Toggle(isOn: $contentHasShadow) {
                Text("Content has shadow")
            }
            .toggleStyle(CheckboxToggleStyle())
            
            Spacer()
        }
    }
}

private struct ContentBackgroundVisualEffect: View {
    @AppStorage(UseContentBackgroundVisualEffectKey) var useContentBackgroundVisualEffect: Bool = false

    var body: some View {
        HStack {
            Toggle(isOn: $useContentBackgroundVisualEffect) {
                Text("Using visual effect")
            }
            .toggleStyle(CheckboxToggleStyle())

            Spacer()
            
            ContentBackGroundVisualEffectMaterial()
                .disabled(!useContentBackgroundVisualEffect)
        }
    }
}

private struct ContentBackGroundVisualEffectMaterial: View {
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
    let allCases: [(Int, String)] = [
        (NSVisualEffectView.Material.titlebar.rawValue, "titlebar"),
        (NSVisualEffectView.Material.selection.rawValue, "selection"),
        (NSVisualEffectView.Material.menu.rawValue, "menu"),
        (NSVisualEffectView.Material.popover.rawValue, "popover"),
        (NSVisualEffectView.Material.sidebar.rawValue, "sidebar"),
        (NSVisualEffectView.Material.headerView.rawValue, "headerView"),
        (NSVisualEffectView.Material.sheet.rawValue, "sheet"),
        (NSVisualEffectView.Material.windowBackground.rawValue, "windowBackground"),
        (NSVisualEffectView.Material.hudWindow.rawValue, "hudWindow"),
        (NSVisualEffectView.Material.fullScreenUI.rawValue, "fullScreenUI"),
        (NSVisualEffectView.Material.toolTip.rawValue, "toolTip"),
        (NSVisualEffectView.Material.contentBackground.rawValue, "contentBackground"),
        (NSVisualEffectView.Material.underWindowBackground.rawValue, "underWindowBackground"),
        (NSVisualEffectView.Material.underPageBackground.rawValue, "underPageBackground")
    ]
    
    var body: some View {
        Picker("", selection: $contentBackGroundVisualEffectMaterial) {
            ForEach(allCases, id: \.self.0) { option in
                Text(option.1).tag(option.0)
            }
        }
        .frame(width: 200)
        .pickerStyle(MenuPickerStyle())
    }
}

private struct ColorSchemeSetting: View {
    @AppStorage(TheColorSchemeKey) var theColorScheme: Int = TheColorScheme.system.rawValue

    var body: some View {
        HStack {
            Text("Color scheme")
            Spacer()
            Picker("", selection: $theColorScheme) {
                Text("Light").tag(TheColorScheme.light.rawValue)
                Text("Dark").tag(TheColorScheme.dark.rawValue)
                Text("System").tag(TheColorScheme.system.rawValue)
                Text("System reversed").tag(TheColorScheme.systemReversed.rawValue)
            }
            .labelsHidden()
            .pickerStyle(MenuPickerStyle())
            .frame(width: 172)
            .help("This will effect on visual effect background and system colors.")
            
            MiniInfoView {
                ColorSchemeInfo()
            }
        }
    }
}

private struct ColorSchemeInfo: View {
    var body: some View {
        Text("Note: if you select System or System Reversed, then I suggest you select system color as well, otherwise, the color can't be adaptable both on light and dark system mode. You can open the color panel, select the Color Palettes tab, then select Developer option, the colors there are all system colors.")
            .infoStyle()
    }
}

private struct ContentPaddingStyleSettingsView: View {
    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    @AppStorage(MinimalistVPaddingKey) var minimalistVPadding: Double = 2.0
    @AppStorage(MinimalistHPaddingKey) var minimalistHPadding: Double = 6.0
    
    var body: some View {
        HStack {
            Picker("Padding style:", selection: $contentPaddingStyle) {
                Text("standard").tag(ContentPaddingStyle.standard.rawValue)
                Text("minimalist").tag(ContentPaddingStyle.minimalist.rawValue)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 250)
            
            Spacer()
            
            if ContentPaddingStyle(rawValue: contentPaddingStyle) == .minimalist {
                Group {
                    Text("Bpad:")
                    TextField("", value: $minimalistVPadding, formatter: tfDecimalFormatter).frame(width: tfSmallWidth)
                    
                    Text("Hpad:")
                    TextField("", value: $minimalistHPadding, formatter: tfDecimalFormatter).frame(width: tfSmallWidth)
                    
                    Button(action: {
                        minimalistVPadding = 2.0
                        minimalistHPadding = 6.0
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
        }
    }
}

private struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) var cropperStyle: Int = CropperStyleDefault

    var body: some View {
        Picker("Cropper style:", selection: $cropperStyle) {
            Text("empty").tag(CropperStyle.empty.rawValue)
            Text("rectangle").tag(CropperStyle.rectangle.rawValue)
            Text("strokeBorder").tag(CropperStyle.strokeBorder.rawValue)
            
            Divider()
            
            Text("leadingBorder").tag(CropperStyle.leadingBorder.rawValue)
            Text("trailingBorder").tag(CropperStyle.trailingBorder.rawValue)
            Text("topBorder").tag(CropperStyle.topBorder.rawValue)
            Text("bottomBorder").tag(CropperStyle.bottomBorder.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 250)
    }
}

private struct IsShowToastView: View {
    @AppStorage(IsShowToastKey) var isShowToast: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowToast, label: {
            Text("Show toast")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct SceneSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SceneSettingsView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
            
            
            ColorSchemeInfo()
        }
    }
}
