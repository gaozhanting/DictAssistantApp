//
//  CropData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/31.
//

import Foundation
import Combine

class CropData: ObservableObject {
    @Published var x: CGFloat
    @Published var y: CGFloat
    @Published var width: CGFloat
    @Published var height: CGFloat
    
    init() {
        if UserDefaults.standard.object(forKey: "cropper.x") != nil {
            self.x = CGFloat(UserDefaults.standard.double(forKey: "cropper.x"))
        } else {
            self.x = 200 + 100
        }
        
        if UserDefaults.standard.object(forKey: "cropper.y") != nil {
            self.y = CGFloat(UserDefaults.standard.double(forKey: "cropper.y"))
        } else {
            self.y = 200 + 100
        }
        
        if UserDefaults.standard.object(forKey: "cropper.width") != nil {
            self.width = CGFloat(UserDefaults.standard.double(forKey: "cropper.width"))
        } else {
            self.width = 200 + 100
        }
        
        if UserDefaults.standard.object(forKey: "cropper.height") != nil {
            self.height = CGFloat(UserDefaults.standard.double(forKey: "cropper.height"))
        } else {
            self.height = 200 + 100
        }
    }
}
