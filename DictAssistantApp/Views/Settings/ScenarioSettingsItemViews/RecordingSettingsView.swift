//
//  RecordingSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI

struct MaximumFrameRateSetting: View {
    @AppStorage(MaximumFrameRateKey) var maximumFrameRate: Double = 4
    
    func useDefault() {
        maximumFrameRate = 4
    }
    
    var body: some View {
        HStack {
            Text("Screen recording FPS:")
            TextField("", value: $maximumFrameRate, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 1
                formatter.maximum = 30
                return formatter
            }()).frame(width: tfWidth)
            
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            
            MiniInfoView {
                InfoView()
            }
            
            Spacer()
        }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("Set the maximum frame rate of the screen capture recording, default is 4 fps which is a decent value for normal usage. \nThe higher the value, the more swift the App react to the cropper screen content changing, but the more CPU it consumes. 4 to 30 is all OK. \nNotice, if you need to set the text recognition level accurate at the same time, you need to set a lower value, for example 4. Because when set as a higher value, it maybe get stuck because it just can't do so much heavy lifting in such a little time.")
            .infoStyle()
    }
}

struct RecordingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
