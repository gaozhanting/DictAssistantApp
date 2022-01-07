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
            ContentMaxSettingsView()
            ContentPaddingStyleSettingsView()
            FontSizeSettingView()
            FontLineSpacingSettingView()
            
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
                    UsesLanguageCorrectionSetting().padding(.top)
                    MinimumTextHeightSetting()
                }
            }
            
            MaximumFrameRateSetting()
            
            LemmaSearchLevelPicker()
            
            Spacer().frame(height: 20)
            Divider()
        }
    }
    
    var g3: some View {
        Group {
            AddLineBreakBeforeTranslationToggle()
            AddSpaceBeforeTranslationToggle()
            Spacer().frame(height: 20)
            Divider()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            g1
            g2
            g3
            HighlightSettingsView()
        }
        .padding()
        .frame(width: panelWidth)
    }
}

struct ScenarioSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioSettingsView()
    }
}
