//
//  DictBuildWithInfoView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import SwiftUI

struct DictBuildWithInfoView: View {
    var body: some View {
        VStack {
            Spacer()
            
            GroupBox {
                DictBuildView()
            }
            .padding()
            
            Spacer()
            
            DictBuildInfoView()
        }
    }
}

private struct DictBuildInfoView: View {
    var body: some View {
        HStack {
            Spacer()
            
            QuestionMarkView {
                InfoView()
            }
        }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("These dictionaries files are some free concise dictionaries I searched from the internet and converted to Apple dictionary format files for you, using an open source tool called pyglossary. These dictionaries, as a complement and third party dictionaries of the system built in dictionary of Apple Dictionary.app, is suitable for this App because these are concise and free. Notice it may have different translation text style, and you could select and deselect some content display options to get a better view.\n\nOf course, you can use built-in dictionary, or other third party dictionaries for Apple Dictionary.app. The database of this App is come from these file through Apple Dictionary.app. It is local and offline.\n\nYou just need to click the install button, and then a save panel will prompt, because it need your permission to save the file at the specific built-in Apple Dictionary.app dictionaries folder, you need to use the default path provided. When all have done, you could open the Dictionary.app preferences to select and re-order them; my recommendation is to order the concise dictionary first, then more detailed dictionary after, anyhow, you are free as your wish.")
            .font(.callout)
            .padding()
            .frame(width: 520)
    }
}

struct DictBuildWithInfoView_Previews: PreviewProvider {
    @AppStorage(RemoteDictURLStringKey) private var remoteDictURLString: String = ""
    
    static var previews: some View {
        Group {
            DictBuildWithInfoView()
            InfoView()
        }
//        .environment(\.locale, .init(identifier: "zh-Hans"))
        .environment(\.locale, .init(identifier: "en"))
    }
}
