//
//  ScenarioSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct ScenarioSettingsView: View {
    var g1: some View {
        Group {
            GroupBox {
                ContentMaxSettingsView()
            }
            GroupBox {
                HStack {
                    FontSizeSettingView()
                    Spacer()
                    FontLineSpacingSettingView()
                }
            }
            
            ContentPaddingStyleSettingsView()
            CropperStyleSettingView()
            
            Spacer().frame(height: 20)
            Divider()
        }
    }
    
    var g2: some View {
        Group {
            GroupBox {
                VStack(alignment: .leading) {
                    RecognitionLevelSetting()
                    MinimumTextHeightSetting()
                }
            }
            
            MaximumFrameRateSetting()
            
            IsOpenLemmaToggle()
            
            Spacer().frame(height: 20)
            Divider()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            g1
            g2
            HighlightSettingsView()
        }
        .padding()
        .frame(width: panelWidth)
    }
}

struct ContentMaxSettingsView: View {
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 160.0
    
    var body: some View {
        HStack {
            Text("Max Height Per Entry:")
            TextField("", value: $portraitMaxHeight, formatter: tfDecimalFormatter).frame(width: tfWidth)
            
            Spacer()
            
            Text("Max Width Per Entry:")
            TextField("", value: $landscapeMaxWidth, formatter: tfDecimalFormatter).frame(width: tfWidth)
        }
    }
}

struct ContentPaddingStyleSettingsView: View {
    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    @AppStorage(StandardCornerRadiusKey) var standardCornerRadius: Double = 6.0
    @AppStorage(MinimalistVPaddingKey) var minimalistVPadding: Double = 2.0
    @AppStorage(MinimalistHPaddingKey) var minimalistHPadding: Double = 6.0
    
    var body: some View {
        HStack {
            Picker("Padding Style:", selection: $contentPaddingStyle) {
                Text("standard").tag(ContentPaddingStyle.standard.rawValue)
                Text("minimalist").tag(ContentPaddingStyle.minimalist.rawValue)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 250)
            
            Spacer()
            
            switch ContentPaddingStyle(rawValue: contentPaddingStyle)! {
            case .standard:
                Group {
                    Text("Radius:")
                    TextField("", value: $standardCornerRadius, formatter: tfDecimalFormatter).frame(width: tfWidth)
                    
                    Button(action: {
                        standardCornerRadius = 6.0
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            case .minimalist:
                Group {
                    Text("Vpad:")
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

struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) var cropperStyle: Int = CropperStyleDefault

    var body: some View {
        Picker("Cropper Style:", selection: $cropperStyle) {
            Text("empty").tag(CropperStyle.empty.rawValue)
            Text("rectangle").tag(CropperStyle.rectangle.rawValue)
            Text("strokeBorder").tag(CropperStyle.strokeBorder.rawValue)
            
            Text("leadingBorder").tag(CropperStyle.leadingBorder.rawValue)
            Text("trailingBorder").tag(CropperStyle.trailingBorder.rawValue)
            Text("topBorder").tag(CropperStyle.topBorder.rawValue)
            Text("bottomBorder").tag(CropperStyle.bottomBorder.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 250)
    }
}

struct ScenarioSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioSettingsView()
    }
}
