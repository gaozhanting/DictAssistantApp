//
//  ScenarioSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/19.
//

import SwiftUI

struct ScenarioSettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ContentStyleSettingView()
            
            Divider()
            CropperStyleSettingView()
            CloseCropperWhenNotPlayingToggle()
            
//            Divider()
//            HighlightView()
//            HighlightSchemeView()
//
            Divider()
            TRMinimumTextHeightSetting()
            TRTextRecognitionLevelSetting()
            
            Divider()
            MaximumFrameRateSetting()
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
