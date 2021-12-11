//
//  CropperView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/28.
//

import SwiftUI

struct StrokeBorderCropperAnimationView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [4], dashPhase: phase))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.5))
            .onAppear {
                withAnimation(.default.repeatForever(autoreverses: false)) {
                    phase -= 4 * 2 // dash * 2
                }
            }
            .ignoresSafeArea()
    }
}

struct StrokeBorderCropperView: View {
    @EnvironmentObject var hlBox: HLBox
    
    var body: some View {
        Rectangle()
            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [4], dashPhase: 0))
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .path(in: {
                            let rect = CGRect(
                                x: hlBox.box.0.x * geometry.size.width,
                                y: hlBox.box.0.y,
                                width: (hlBox.box.1.x - hlBox.box.0.x) * geometry.size.width,
                                height: (hlBox.box.3.y - hlBox.box.0.y) * geometry.size.height
                            )
                            print(">>]] highlightBounds: \(hlBox.box)")
                            print(">>]] rect: \(rect)")
                            return rect
                        }())
                        .fill(Color.yellow.opacity(0.2))
//                        .border(.purple)
//                        .border(width: 2, edges: [.bottom], color: .orange)

//                    Rectangle()
//                        .path(in: rect)
////                        .fill(Color.red)
//                        .stroke(Color.red, lineWidth: 2.0)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

struct RectangleCropperView: View {
    var body: some View {
        Spacer()
            .background(Color.accentColor.opacity(0.1))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

struct LeadingBorderCropperView: View {
    var body: some View {
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .border(width: 5, edges: [.leading], color: Color.accentColor)
    }
}

struct TrailingBorderCropperView: View {
    var body: some View {
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .border(width: 5, edges: [.trailing], color: Color.accentColor)
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {

    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

struct CropperView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            StrokeBorderCropperAnimationView()
            StrokeBorderCropperView()
//            RectangleCropperView()
//            LeadingBorderCropperView()
//            TrailingBorderCropperView()
        }
    }
}
