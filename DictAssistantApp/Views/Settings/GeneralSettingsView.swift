//
//  GeneralSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/22.
//

import SwiftUI
import Vision
import Preferences
import KeyboardShortcuts

let settingPanelWidth: Double = 600.0

struct GeneralSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Global Keyboard Shortcuts:", comment: "")) {
                KeyRecordingView(onboarding: false)
                    .frame(maxWidth: .infinity)
            }
            Preferences.Section(title: NSLocalizedString("Minimum Text Height:", comment: "")) {
                GroupBox {
                    VStack(alignment: .leading) {
                        TRMinimumTextHeightSetting()
                    }
                }
            }
            Preferences.Section(title: NSLocalizedString("Text Recognition Level:", comment: "")) {
                GroupBox {
                    VStack(alignment: .leading) {
                        TRTextRecognitionLevelSetting()
                    }
                }
            }
            Preferences.Section(title: NSLocalizedString("Maximum Frame Rate:", comment: "")) {
                MaximumFrameRateSetting()
            }
        }
    }
}

struct MiniInfoView<Content: View>: View {
    let arrowEdge: Edge
    let content: Content
    
    init(arrowEdge: Edge = .top, @ViewBuilder content: () -> Content) {
        self.arrowEdge = arrowEdge
        self.content = content()
    }
    
    @State private var isShowingPopover = false
    
    var body: some View {
        Button(action: { isShowingPopover = true }, label: {
            Image(systemName: "info.circle")
                .font(.footnote)
        })
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $isShowingPopover, arrowEdge: arrowEdge) {
            content
        }
    }
}

struct KeyRecordingView: View {
    let onboarding: Bool
    
    var body: some View {
        Group {
            HStack {
                Text("Run Flow Step:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleFlowStep)
                MiniInfoView {
                    Text("recommend: Option-1").padding()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Show Current Known Words:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnownWords)
                MiniInfoView {
                    Text("recommend: Option-2").padding()
                }
            }
            if !onboarding {
                HStack(alignment: .firstTextBaseline) {
                    Text("Toggle Conceal Current Known Words:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnownWordsButWithOpacity0)
                    MiniInfoView {
                        Text("recommend: Option-3").padding()
                    }
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("Toggle Conceal Translation:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleConcealTranslation)
                    MiniInfoView {
                        Text("recommend: Option-4").padding()
                    }
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("Toggle Show Current Not-Found Words:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleShowCurrentNotFoundWords)
                    MiniInfoView {
                        Text("recommend: Option-5").padding()
                    }
                }
            }
        }
    }
}

fileprivate struct TRMinimumTextHeightSetting: View {
    @AppStorage(TRMinimumTextHeightKey) private var minimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    
    func resetToDefault() {
        minimumTextHeight = systemDefaultMinimumTextHeight
    }
    
    func incrementStep() {
        minimumTextHeight += 0.01
        if minimumTextHeight > 1 {
            minimumTextHeight = 1
        }
    }
    
    func decrementStep() {
        minimumTextHeight -= 0.01
        if minimumTextHeight < 0 {
            minimumTextHeight = 0
        }
    }
    
    var body: some View {
        HStack {
            Text("\(minimumTextHeight, specifier: "%.4f")")
            Slider(
                value: $minimumTextHeight,
                in: 0...1
            )
            .frame(maxWidth: 180)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
        }
        
        Button("Reset to default: 0.0315", action: resetToDefault)
        
        HStack {
            Text("The minimum height of the text expected to be recognized, relative to the image height.")
                .preferenceDescription()
                .frame(width: 300, height: 30, alignment: .leading)
            
            MiniInfoView(arrowEdge: .trailing) {
                MiniHeigthInfoPopoverView()
            }
        }
    }
}

fileprivate struct MiniHeigthInfoPopoverView: View {
    var body: some View {
        Text("Specify a floating-point number relative to the image height. \nFor example, to limit recognition to text that is half of the image height, use 0.5. Increasing the size reduces memory consumption and expedites recognition with the tradeoff of ignoring text smaller than the minimum height. \nThe default value is 1/32, or 0.03125.")
            .font(.subheadline)
            .padding()
            .frame(width: 300, height: 150)
    }
}

fileprivate struct TRTextRecognitionLevelSetting: View {
    @AppStorage(TRTextRecognitionLevelKey) private var textRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    
    var body: some View {
        Picker("", selection: $textRecognitionLevel) {
            Text("fast").tag(VNRequestTextRecognitionLevel.fast.rawValue)
            Text("accurate").tag(VNRequestTextRecognitionLevel.accurate.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
        
        if textRecognitionLevel == VNRequestTextRecognitionLevel.fast.rawValue {
            Text("Fast is very fast, and cause low CPU usage, you should use this by default, but terrible when text on screen has tough surrounding!")
                .preferenceDescription()
                .frame(width: 300, height: 50, alignment: .leading)
        } else {
            (Text("Accurate is the only rescue when the text is hard to recognized in screen! ")
                 + Text("Accurate will cause high CPU usage!").foregroundColor(.red))
                .preferenceDescription()
                .frame(width: 300, height: 50, alignment: .leading)
        }
    }
}

fileprivate struct MaximumFrameRateSetting: View {
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    @EnvironmentObject var statusData: StatusData
    
    var body: some View {
        HStack {
            TextField("", value: $maximumFrameRate, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 1
                formatter.maximum = 30
                return formatter
            }())
            .frame(width: 46)
            .disabled(statusData.isPlaying)
            
            Button("Use default") {
                maximumFrameRate = 4
            }
            .disabled(statusData.isPlaying)
            
            MiniInfoView(arrowEdge: Edge.trailing) {
                MaximumFrameRateInfoPopoverView()
            }
        }
    }
}

fileprivate struct MaximumFrameRateInfoPopoverView: View {
    var body: some View {
        Text("Set the maximum frame rate of the screen capture recording, default is 4fps which is a decent value for normal usage. \nThe higher the value, the more swift the APP react to the cropper screen content changing, but the more CPU it consumes. 1 to 30 is all OK.\nThe animation duration normally is 1/number. \nNotice, if you set a number less than 4, that will still use 4 as the fps, but the animation duration is still 1/number. \nNotice, if you need to set the text recognition level accurate at the same time, you need to set a lower value, for example 4. Because when set as a higher value, it maybe get stuck because it just can't do so much heavy lifting in such a little time.")
            .font(.subheadline)
            .padding()
            .frame(width: 300, height: 250)
    }
}

struct GeneralSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeneralSettingsView()
                .environmentObject(StatusData(isPlaying: false))
                .frame(width: CGFloat(settingPanelWidth), height: 500)
            
            MiniHeigthInfoPopoverView()
            
            MaximumFrameRateInfoPopoverView()
        }
        .environment(\.locale, .init(identifier: "en"))
    }
}
