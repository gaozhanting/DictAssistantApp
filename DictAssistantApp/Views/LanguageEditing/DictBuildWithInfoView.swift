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
            
            DictBuildView()
                .frame(minWidth: 650, maxWidth: .infinity)
            
            Spacer()
            
            DictBuildInfoView()
        }
    }
}

struct BuildingImageView: View {
    @Binding var isBuilding: Bool
    
    @State var degree: Double = 0
    
    var body: some View {
        if !isBuilding {
            Image(systemName: "hammer")
        } else {
            Image(systemName: "hammer")
                .rotationEffect(.degrees(degree))
                .onAppear {
                    withAnimation(.default.repeatForever(autoreverses: true)) {
                        degree = 40
                    }
                }
                .onDisappear { // this is important
                    degree = 0
                }
        }
    }
}

private struct DictBuildView: View {
    @AppStorage(RemoteDictURLStringKey) private var remoteDictURLString: String = ""
    
    @State var text: String = ""
    @State var isBuilding: Bool = false
    
    var body: some View {
        VStack {
            GroupBox(label: Label("Current Local Dictionary Built From:", systemImage: "building.columns")
                        .font(.title2)) {
                TextField("", text: Binding.constant(remoteDictURLString))
            }
            
            Spacer().frame(height: 30)
            
            GroupBox(label: Label("Rebuild From:", systemImage: "hammer")
                        .font(.title2)) {
                
                TextField("url", text: $text)
                
                Button(action: {
                    isBuilding = true
                    batchResetRemoteEntries(
                        from: text,
                        didSucceed: {
                            DispatchQueue.main.async {
                                remoteDictURLString = text
                                
                                currentEntries = getAllRemoteEntries() // 3s
                                logger.info("]] getAllRemoteEntries done!")
                                
                                cachedDict = [:]
                                trCallBack()
                                logger.info("]] trCallBack done!")
                                
                                isBuilding = false
                            }
                        },
                        didFailed: {
                            DispatchQueue.main.async {
                                isBuilding = false
                            }
                        }
                    )
                }) {
                    BuildingImageView(isBuilding: $isBuilding)
                }
                .disabled(isBuilding)
            }
        }
        .padding()
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
        Text("We simply build our local concise dictionary from a remote simple CSV format file. In this file, every single line is an entry which only includes the title word and the translated text, nothing more.")
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
