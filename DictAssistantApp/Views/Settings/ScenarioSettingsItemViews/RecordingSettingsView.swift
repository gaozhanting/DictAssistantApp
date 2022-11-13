//
//  RecordingSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI

struct MaximumFrameRateSetting: View {
    @AppStorage(MaximumFrameRateKey) var maximumFrameRate: Int = MaximumFrameRateDefault
    
    func useDefault() {
        maximumFrameRate = MaximumFrameRateDefault
    }
    
    var body: some View {
        HStack {
            Text("Screen recording FPS:")
            TextField("", value: $maximumFrameRate, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 1
                formatter.maximum = 10
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
        Text("Set the maximum frame rate of the screen capture recording, default is 3 which is a decent value for normal stream usage, for example video subtitle.\n\nThe higher the value, the more swift the App react to the cropper screen content changing, but the it consumes much more CPU. 1 to 10 are all OK.")
            .infoStyle()
    }
}

struct RecordingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
