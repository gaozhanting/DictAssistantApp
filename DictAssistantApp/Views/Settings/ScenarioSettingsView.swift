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
            ContentStyleSettingView()
            
            CropperStyleSettingView()
        }
    }
    
    var g2: some View {
        Group {
            TRMinimumTextHeightSetting()
            TRTextRecognitionLevelSetting()
            
            MaximumFrameRateSetting()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            g1
            
            Spacer().frame(height: 20)
            Divider()
            
            g2
            
            Spacer().frame(height: 30)
            Divider()
            
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
