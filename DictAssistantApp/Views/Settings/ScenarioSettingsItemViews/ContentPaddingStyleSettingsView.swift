//
//  ContentPaddingStyleSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/22.
//

import SwiftUI

struct ContentPaddingStyleSettingsView: View {
    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    @AppStorage(StandardCornerRadiusKey) var standardCornerRadius: Double = 6.0
    @AppStorage(MinimalistVPaddingKey) var minimalistVPadding: Double = 2.0
    @AppStorage(MinimalistHPaddingKey) var minimalistHPadding: Double = 6.0
    
    var body: some View {
        HStack {
            Picker("Content Padding Style:", selection: $contentPaddingStyle) {
                Text("Standard").tag(ContentPaddingStyle.standard.rawValue)
                Text("Minimalist").tag(ContentPaddingStyle.minimalist.rawValue)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 250)
            
            Spacer()
            
            switch ContentPaddingStyle(rawValue: contentPaddingStyle)! {
            case .standard:
                Group {
                    Text("Radius:")
                    TextField("", value: $standardCornerRadius, formatter: tfDecimalFormatter).frame(width: tfWidth)
                    Button(action: {
                        standardCornerRadius = 10.0
                    }) {
                        Image(systemName: "pencil.and.outline")
                    }
                }
            case .minimalist:
                Group {
                    Text("Vpad:")
                    TextField("", value: $minimalistVPadding, formatter: tfDecimalFormatter).frame(width: tfSmallWidth)
                    
                    Text("Hpad:")
                    TextField("", value: $minimalistHPadding, formatter: tfDecimalFormatter).frame(width: tfSmallWidth)
                    
                    Button(action: {
                        minimalistVPadding = 2.0
                        minimalistHPadding = 6.0
                    }) {
                        Image(systemName: "pencil.and.outline")
                    }
                }
            }
            
        }
    }
}

//struct ContentPaddingStyleSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentPaddingStyleSettingsView()
//    }
//}
