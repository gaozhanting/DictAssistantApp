//
//  NLPSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/17.
//

import SwiftUI
import Preferences

struct NLPSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Lemma Search Level:", comment: "")) {
                LemmaSearchLevelPicker()
            }
            Preferences.Section(title: NSLocalizedString("More Recognitions:", comment: "")) {
                DoNameRecognitionToggle()
                DoPhraseRecognitionToggle()
            }
        }
    }
}

private struct LemmaSearchLevelPicker: View {
    @AppStorage(LemmaSearchLevelKey) private var lemmaSearchLevel: Int = LemmaSearchLevel.database.rawValue
    
    var body: some View {
        HStack {
            Picker("", selection: $lemmaSearchLevel) {
                Text("apple").tag(LemmaSearchLevel.apple.rawValue)
                Text("database").tag(LemmaSearchLevel.database.rawValue)
                Text("open").tag(LemmaSearchLevel.open.rawValue)
            }
            .labelsHidden()
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
            
            MiniInfoView {
                LemmaSearchLevelInfoView()
            }
        }
    }
}

private struct LemmaSearchLevelInfoView: View {
    var body: some View {
        Text("Select apple when you want to exclude invalid words which has no lemma by using Apple NLP lemma method. \nSelect database when you want include more valid words those lemma Apple not includes but our specific lemma database does. \nSelect open when you want include all words, with the risk of all invalid words which are called noises may come out.")
            .infoStyle()
    }
}

private struct DoNameRecognitionToggle: View {
    @AppStorage(DoNameRecognitionKey) var doNameRecognition: Bool = false
    
    var body: some View {
        Toggle(isOn: $doNameRecognition, label: {
            Text("Do Name Recognition")
        })
    }
}

private struct DoPhraseRecognitionToggle: View {
    @AppStorage(DoPhraseRecognitionKey) private var doPhraseRecognition: Bool = false
    
    var body: some View {
        Toggle(isOn: $doPhraseRecognition, label: {
            Text("Do Phrase Reccognition")
        })
            .toggleStyle(CheckboxToggleStyle())
    }
}

struct NLPSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NLPSettingsView()
    }
}
