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
        SceneSettingsView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
