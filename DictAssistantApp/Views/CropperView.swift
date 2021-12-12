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

struct HLBoxView: View {
    let box: ((CGPoint, CGPoint)) // topLeft, bottomRight, (x, y) all are decimal fraction
    let geometrySize: CGSize
    
    var body: some View {
        Rectangle()
            .path(in: {
                let rect = CGRect(
                    x: box.0.x * geometrySize.width,
                    y: (1 - box.0.y) * geometrySize.height, // notice here 1-y
                    width: abs(box.1.x - box.0.x) * geometrySize.width,
                    height: abs(box.1.y - box.0.y) * geometrySize.height
                )
                print(">>]] highlightBounds box: \(box)")
                print(">>]] rect: \(rect)")
                return rect
            }())
            .fill(Color.yellow.opacity(0.2))
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct StrokeBorderCropperView: View {
    @EnvironmentObject var hlBox: HLBoxs
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [4], dashPhase: 0))
                
                ForEach(hlBox.boxs, id: \.self.0) { box in
                    HLBoxView(box: box, geometrySize: geometry.size)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct CropperView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            StrokeBorderCropperAnimationView()
            StrokeBorderCropperView()
                .frame(width: 1087, height: 282)
                .environmentObject(
                    HLBoxs(boxs: [
                        (CGPoint(x: 0.026194852941176485, y: 0.9134275618374559),
                         CGPoint(x: 0.15073529411764705, y: 0.7773851590106007)),
                        
                        (CGPoint(x: 0.024356617647058848, y: 0.646643109540636),
                         CGPoint(x: 0.3795955882352941, y: 0.5512367491166077)),
                        
                        (CGPoint(x: 0.025735294117647058, y: 0.39399293286219084),
                         CGPoint(x: 0.21599264705882354, y: 0.2720848056537103)),
                        
                        (CGPoint(x: 0.02435661764705881, y: 0.12367491166077738),
                         CGPoint(x: 0.17325367647058823, y: 0.04770318021201414)),
                        
                        (CGPoint(x: 0.7527573529411765, y: 0.12367491166077738),
                         CGPoint(x: 0.7936580882352942, y: 0.04770318021201414))
                    ])
                )
//            RectangleCropperView()
//            LeadingBorderCropperView()
//            TrailingBorderCropperView()
        }
    }
}
