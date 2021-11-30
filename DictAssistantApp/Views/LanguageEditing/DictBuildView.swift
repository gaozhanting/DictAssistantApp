//
//  DictBuildView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/11/30.
//

import SwiftUI

struct DictBuildView: View {
    @AppStorage(RemoteDictURLStringKey) private var remoteDictURLString: String = ""
    
    @State var text: String = ""
    @State var isBuilding: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .trailing) {
                HStack {
                    Text("Current Dict Built From:")
                    TextField("", text: $remoteDictURLString)
                        .frame(width: 450)
                        .disabled(true)
                }
                
                HStack {
                    Text("Build From:")
                    TextField("url", text: $text)
                        .frame(width: 450)
                }
            }
            
            HStack {
                Button("build") {
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
                }
                .disabled(isBuilding)
                
                if isBuilding == true {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                }
            }
        }
        .padding()
        .frame(minWidth: 650, maxWidth: .infinity)
    }
}

struct DictBuildView_Previews: PreviewProvider {
    static var previews: some View {
        DictBuildView()
    }
}
