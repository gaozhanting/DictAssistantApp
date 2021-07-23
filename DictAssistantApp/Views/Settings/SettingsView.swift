//
//  SettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/20.
//

import SwiftUI

struct SettingsView: View {
    private let tabs = ["General", "Appearance", "Dictionaries"]
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Picker("", selection: $selectedTabIndex) {
                    ForEach(tabs.indices) { i in
                        Text(tabs[i]).tag(i)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 8)
                Spacer()
            }
            
            Divider()
            
            GeometryReader { gp in // ???
                ChildTabView(
                    title: tabs[selectedTabIndex],
                    index: selectedTabIndex
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChildTabView: View {
    var title: String
    var index: Int
    
    var body: some View {
        if index == 0 {
            GeneralSettingsView()
        } else if index == 1 {
            AppearanceSettingsView()
        } else if index == 2 {
            DictionariesView()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(width: 500, height: 500)
    }
}
