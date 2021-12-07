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
                        degree = 50
                    }
                }
                .onDisappear { // this is important
                    degree = 0
                }
        }
    }
}

struct BuildActionView: View {
    let buildFrom: String
    
    @AppStorage(RemoteDictURLStringKey) private var remoteDictURLString: String = ""
    
    @State var isBuilding: Bool = false
    
    @State var succeed: Bool = false
    func toastSucceed() {
        withAnimation {
            succeed = true
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                succeed = false
            }
        }
    }
    
    var body: some View {
        if succeed {
            Text("Succeed")
                .transition(.move(edge: .bottom))
        } else {
            Button(action: {
                isBuilding = true
                batchResetRemoteEntries(
                    from: buildFrom,
                    didSucceed: {
                        DispatchQueue.main.async {
                            remoteDictURLString = buildFrom
                            
                            cachedDict = [:]
                            trCallBack()
                            logger.info("]] trCallBack done!")
                            
                            isBuilding = false
                            toastSucceed()
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
}

private struct DictBuildView: View {
    @AppStorage(RemoteDictURLStringKey) private var remoteDictURLString: String = ""
    
    @State var remoteFrom: String = ""
    
    var body: some View {
        VStack {
            GroupBox(label: Label("Current Local Dictionary Built From:", systemImage: "building.columns")
                        .font(.title2)) {
                TextField("", text: Binding.constant(remoteDictURLString))
            }
            
            Spacer().frame(height: 50)
            
            GroupBox(label: Label("Rebuild From Remote File:", systemImage: "hammer")
                        .font(.title2)) {
                VStack {
                    TextField("url", text: $remoteFrom)
                    BuildActionView(buildFrom: remoteFrom)
                }
            }
            
            GroupBox(label: Label("Rebuild From Local File:", systemImage: "hammer").font(.title2)) {
                VStack {
                    HStack {
                        Button("open") {
                            openLocalFile { localURL in
                                localFrom = localURL.absoluteString
                            }
                        }
                        TextField("", text: Binding.constant(localFrom))
                            .disabled(true)
                    }
                    
                    BuildActionView(buildFrom: localFrom)
                }
            }
        }
        .padding()
    }
    
    @State var localFrom: String = ""
    
    func openLocalFile(didSelected: @escaping (_ localURL: URL) -> Void) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            
            guard panel.runModal() == .OK else {
                logger.info("panel runModal not return OK, refused.")
                return
            }
            
            guard let url = panel.urls.first else {
                logger.info("panel not select a file.")
                return
            }
            
            logger.info("url is:\(url.absoluteString)")
            
            didSelected(url)
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
        Text("We simply build our local concise dictionary from a simple CSV format file. In this file, every single line is an entry which only includes the title word and the translated text, nothing more.")
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
