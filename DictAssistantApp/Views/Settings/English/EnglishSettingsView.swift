//
//  EnglishSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Preferences

struct EnglishSettingsView: View {
    var body: some View {
        TabView {
            Preferences.Container(contentWidth: settingPanelWidth) {
                Preferences.Section(title: NSLocalizedString("Show Phrases:", comment: "")) {
                    ShowPhrasesToggle()
                }
                Preferences.Section(title: NSLocalizedString("Use Entry Mode:", comment: "")) {
                    UseEntryModePicker()
                }
            }
            .padding(.leading, 180)
            .tabItem {
                Text("Options")
            }
            
            VStack {
                GroupBox {
                    PhrasesView()
                }
            }
            .tabItem {
                Text("Phrases")
            }
            
            GroupBox {
                NoiseView()
            }
            .tabItem {
                Text("Noises")
            }
            
            GroupBox {
                KnownView()
            }
            .tabItem {
                Text("Known")
            }
            
            VStack {
                GroupBox {
                    EntryView()
                }
            }
            .tabItem {
                Text("Entries")
            }
            
            VStack {
                Spacer()
                GroupBox {
                    DictInstallView(dict: targetDict())
                }
                .padding()
                Spacer()
                DictInstallInfoView()
            }
            .tabItem {
                Text("Third Party Dict")
            }
            
        }
        .environment(\.managedObjectContext, persistentContainer.viewContext)
        .padding(.top, 10)
        .frame(width: CGFloat(settingPanelWidth))
        .frame(minHeight: 600)
    }
}

private struct DictInstallInfoView: View {
    @State private var isShowingPopover = false

    var body: some View {
        HStack {
            Spacer()
            
            Button(action: { isShowingPopover = true }, label: {
                Image(systemName: "questionmark").font(.body)
            })
            .clipShape(Circle())
            .padding()
            .shadow(radius: 1)
            .popover(isPresented: $isShowingPopover, arrowEdge: .leading, content: {
                InfoView()
            })
        }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("These dictionaries files are some free concise dictionaries I searched from the internet and converted to Apple dictionary format files for you, using an open source tool called pyglossary. These dictionaries, as a complement and third party dictionaries of the system built in dictionary of Apple Dictionary.app, is suitable for this APP because these are concise and free. Notice it may have different translation text style, and you could select and deselect some content display options to get a better view.\n\nOf course, you can use built-in dictionary, or other third party dictionaries for Apple Dictionary.app. The database of this APP is come from these file through Apple Dictionary.app. It is local and offline.\n\nYou just need to click the install button, and then a save panel will prompt, because it need your permission to save the file at the specific built-in Apple Dictionary.app dictionaries folder, you need to use the default path provided. When all have done, you could open the Dictionary.app preferences to select and re-order them; my recommendation is to order the concise dictionary first, then more detailed dictionary after, anyhow, you are free as your wish.")
            .padding()
            .frame(width: 520, height: 340)
    }
}

private struct ShowPhrasesToggle: View {
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowPhrase, label: {
            Text("Show Phrases")
        })
            .toggleStyle(CheckboxToggleStyle())
            .help("Select it when you want display all phrase words.")
    }
}

private struct UseEntryModePicker: View {
    @AppStorage(UseEntryModeKey) private var useEntryMode: UseEntryMode = .asFirstPriority
    
    var binding: Binding<UseEntryMode> {
        Binding(
            get: { useEntryMode },
            set: { newValue in
                useEntryMode = newValue
                cachedDict = [:]
                trCallBack()
            }
        )
    }
    
    var body: some View {
        Picker("", selection: binding) {
            Text("not use").tag(UseEntryMode.notUse)
            Text("as first priority").tag(UseEntryMode.asFirstPriority)
            Text("as last priority").tag(UseEntryMode.asLastPriority)
            Text("only").tag(UseEntryMode.only)
        }
        .labelsHidden()
        .pickerStyle(MenuPickerStyle())
        .frame(width: 200)
        .help("Choose the way you want to use for your custom entries.")
    }
}

struct DictSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EnglishSettingsView()
    }
}
