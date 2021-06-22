//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI
import Vision
//
//struct ControlView: View {
//    @EnvironmentObject var visualConfig: VisualConfig
//    @EnvironmentObject var statusData: StatusData
//    @EnvironmentObject var textProcessConfig: TextProcessConfig
//    @Environment(\.toggleCropper) var toggleCropper
//    @Environment(\.toggleScreenCapture) var toggleScreenCapture
//    @Environment(\.resetUserDefaults) var resetUserDefaults
//    @Environment(\.changeFont) var changeFont
//    @Environment(\.showFonts) var showFonts
//    @Environment(\.showColorPanel) var showColorPanel
//    @Environment(\.toggleContentPanelMiniMode) var toggleContentPanelMiniMode
//    @Environment(\.enterContentPanelMiniMode) var enterContentPanelMiniMode
//
//    @State private var showingDeleteAlert = false
//    
//    @Binding var showHistoryDrawer: Bool
//    
//    var visualConfigDisplayModeBindingWithSideEffect: Binding<DisplayMode> {
//        Binding.init {
//            visualConfig.displayMode
//        } set: { newValue in
//            visualConfig.displayMode = newValue
//            toggleContentPanelMiniMode()
//        }
//    }
//    
////    var playingImage: Image {
////        if statusData.isPlaying {
////            return Image(systemName: "stop.fill")
////        } else {
////            return Image(systemName: "play.fill")
////        }
////    }
//    
//    var body: some View {
//        HStack(alignment: .center) {
//            Button(action: {
//                withAnimation {
//                    toggleCropper()
//                }
//            }, label: {
//                Image(systemName: "rectangle.dashed")
//            })
//            .buttonStyle(PlainButtonStyle())
//
//            Button(action: {
//                showFonts(nil)
//            }, label: {
//                Image(systemName: "f.circle")
//            })
//            .buttonStyle(PlainButtonStyle())
//            
//            Button(action: {
//                showColorPanel()
//            }, label: {
//                Image(systemName: "c.circle")
//            })
//            .buttonStyle(PlainButtonStyle())
//            
//            Button(action: {
//                enterContentPanelMiniMode()
//            }, label: {
//                Image(systemName: "m.circle")
//            })
//            .buttonStyle(PlainButtonStyle())
//            
//            Button(action: {
//                withAnimation {
//                    showHistoryDrawer.toggle()
//                }
//            }, label: {
//                Image(systemName: "clock")
//            })
//            .buttonStyle(PlainButtonStyle())
//
//            Menu("Options") {
//                Picker("TR Level", selection: $textProcessConfig.textRecognitionLevel) {
//                    Text("Fast").tag(VNRequestTextRecognitionLevel.fast)
//                    Text("Accurate").tag(VNRequestTextRecognitionLevel.accurate)
//                }
//                Picker("DisplayMode", selection: visualConfigDisplayModeBindingWithSideEffect) {
//                    Text("Landscape").tag(DisplayMode.landscape)
//                    Text("Portrait").tag(DisplayMode.portrait)
//                }
//            }
//            .menuStyle(BorderlessButtonMenuStyle())
//            .frame(maxWidth: 60)
//
////            playingImage
////                .onTapGesture {
////                    toggleScreenCapture()
////                }
//        }
//        .frame(maxWidth: 250, maxHeight: 45)
//    }
//    
//}
//
//struct ControlView_Previews: PreviewProvider {
//    static var previews: some View {
//        ControlView(showHistoryDrawer: .constant(false))
//            .frame(width: 300, height: 50)
//            .environmentObject(StatusData(isPlayingInner: false, sideEffectCode: {}))
//            .environmentObject(TextProcessConfig(textRecognitionLevel: .fast))
//            .environmentObject(
//                VisualConfig(
//                    miniMode: false,
//                    displayMode: .landscape,
//                    fontSizeOfLandscape: 20,
//                    fontSizeOfPortrait: 13,
//                    colorOfLandscape: .orange,
//                    colorOfPortrait: .green,
//                    fontName: NSFont.systemFont(ofSize: 0.0).fontName))
//            .environment(\.toggleCropper, {})
//            .environment(\.toggleScreenCapture, {})
//    }
//}
