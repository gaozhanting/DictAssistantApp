//
//  NLPSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/17.
//

import SwiftUI
import Preferences

struct LemmaSearchLevelPicker: View {
    @AppStorage(LemmaSearchLevelKey) private var lemmaSearchLevel: Int = LemmaSearchLevel.database.rawValue
    
    var body: some View {
        HStack {
            Text("Lemma Search Level")
            Spacer()
            Picker("", selection: $lemmaSearchLevel) {
                Text("apple").tag(LemmaSearchLevel.apple.rawValue)
                Text("database").tag(LemmaSearchLevel.database.rawValue)
                Text("open").tag(LemmaSearchLevel.open.rawValue)
            }
            .frame(width: 200)
            .pickerStyle(MenuPickerStyle())
            
            MiniInfoView {
                InfoView()
            }
        }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("Select apple when you want to exclude invalid words which has no lemma by using Apple NLP lemma method. \nSelect database when you want include more valid words those lemma Apple not includes but our specific lemma database does. \nSelect open when you want include all words, with the risk of all invalid words which are called noises may come out.")
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
    @AppStorage(DoPhraseDetectionKey) private var doPhraseDetection: Bool = false
    
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
