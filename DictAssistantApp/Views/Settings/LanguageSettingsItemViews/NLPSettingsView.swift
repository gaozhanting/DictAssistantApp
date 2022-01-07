//
//  NLPSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/17.
//

import SwiftUI
import Preferences

struct IsOpenLemmaToggle: View {
    @AppStorage(IsOpenLemmaKey) var isOpenLemma: Bool = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $isOpenLemma) {
                Text("Is Open Lemma")
            }
            .toggleStyle(CheckboxToggleStyle())
            .frame(width: 270)
            
            MiniInfoView {
                InfoView()
            }
        }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("Because our lemma database is not perfect, you can select open when you want include all words, with the risk of all invalid words which are called noises may come out.")
            .infoStyle()
    }
}

struct DoNameRecognitionToggle: View {
    @AppStorage(DoNameRecognitionKey) var doNameRecognition: Bool = false
    
    var body: some View {
        Toggle(isOn: $doNameRecognition, label: {
            Text("Do Name Recognition")
        })
            .toggleStyle(CheckboxToggleStyle())
    }
}

struct DoPhraseDetectionToggle: View {
    @AppStorage(DoPhraseDetectionKey) var doPhraseDetection: Bool = false
    
    var body: some View {
        Toggle(isOn: $doPhraseDetection, label: {
            Text("Do Phrase Detection")
        })
            .toggleStyle(CheckboxToggleStyle())
    }
}

struct NLPSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
