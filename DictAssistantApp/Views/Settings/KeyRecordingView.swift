//
//  KeyRecordingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import SwiftUI
import KeyboardShortcuts

struct KeyRecordingView: View {
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Unicorn Mode:")
                KeyboardShortcuts.Recorder(for: .toggleUnicornMode)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Cancel Unicorn Mode:")
                KeyboardShortcuts.Recorder(for: .cancelUnicornMode)
            }
        }
    }
}

struct KeyRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        KeyRecordingView()
    }
}