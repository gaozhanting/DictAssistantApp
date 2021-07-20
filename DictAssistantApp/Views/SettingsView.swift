//
//  SettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/20.
//

import SwiftUI

//struct SettingsView: View {
//    var body: some View {
//        MTabView()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//struct MTabView: NSViewControllerRepresentable {
//    func makeNSViewController(context: Context) -> some NSViewController {
//        let controller = MNSTabViewController()
//        return controller
//    }
//
//    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
//    }
//}
//
//class MNSTabViewController: NSTabViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let generalSettingViewController = NSHostingController(rootView: GeneralSettingView())
//
//        let appearanceSettingViewController = NSHostingController(rootView: AppearanceSettingView())
//
//        tabStyle = .toolbar
//
//        let gTabViewItem = NSTabViewItem.init(viewController: generalSettingViewController)
//        let aTabViewItem = NSTabViewItem.init(viewController: appearanceSettingViewController)
//        tabViewItems = [gTabViewItem, aTabViewItem]
//    }
//}
//
//struct GeneralSettingView: View {
//    var body: some View {
//        Text("General")
//    }
//}
//
//struct AppearanceSettingView: View {
//    var body: some View {
//        Text("Appearance")
//    }
//}

struct SettingsView: View {
    private let tabs = ["Watch Now", "Movies", "TV Shows", "Kids", "Library"]
    @State private var selectedTab = 0
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Picker("", selection: $selectedTab) {
                    ForEach(tabs.indices) { i in
                        Text(self.tabs[i]).tag(i)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 8)
                Spacer()
            }
            .padding(.horizontal, 100)
            Divider()
            GeometryReader { gp in
                VStack {
                    ChildTabView(title: self.tabs[self.selectedTab], index: self.selectedTab)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChildTabView: View {
    var title: String
    var index: Int
    var body: some View {
        Text("\(title)")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
