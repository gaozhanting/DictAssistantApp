//
//  CropperView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/28.
//

import SwiftUI

struct StrokeBorderCropperAnimationView: View {
    @State var phase: CGFloat = 0
    
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

private struct CropperView: View {
    @AppStorage(CropperStyleKey) var cropperStyle: Int = CropperStyleDefault

    var body: some View {
        switch CropperStyle(rawValue: cropperStyle)! {
        case .empty:
            EmptyView()
        case .rectangle:
            RectangleCropperView()
        case .strokeBorder:
            StrokeBorderCropperView()
            
        case .leadingBorder:
            LeadingBorderCropperView()
        case .trailingBorder:
            TrailingBorderCropperView()
        case .topBorder:
            TopBorderCropperView()
        case .bottomBorder:
            BottomBorderCropperView()
        }
    }
}

private struct StrokeBorderCropperView: View {
    var body: some View {
        Rectangle()
            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [4], dashPhase: 0))
    }
}

private struct RectangleCropperView: View {
    var body: some View {
        Spacer()
            .background(Color.accentColor.opacity(0.1))
    }
}

private struct LeadingBorderCropperView: View {
    var body: some View {
        Spacer()
            .border(width: 3, edges: [.leading], color: Color.accentColor)
    }
}

private struct TrailingBorderCropperView: View {
    var body: some View {
        Spacer()
            .border(width: 3, edges: [.trailing], color: Color.accentColor)
    }
}

private struct TopBorderCropperView: View {
    var body: some View {
        Spacer()
            .border(width: 1, edges: [.top], color: Color.accentColor)
    }
}

private struct BottomBorderCropperView: View {
    var body: some View {
        Spacer()
            .border(width: 1, edges: [.bottom], color: Color.accentColor)
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

private struct EdgeBorder: Shape {
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

private struct HLDottedView: View {
    let index: Int
    let box: ((CGPoint, CGPoint)) // topLeft, bottomRight, (x, y) all are decimal fraction
    let geometrySize: CGSize
    
    @AppStorage(HLDottedColorKey) var hlDottedColor: Data = colorToData(NSColor.red)!
    var hlColor: Color {
        Color(dataToColor(hlDottedColor)!)
    }
    
    @AppStorage(StrokeDownwardOffsetKey) var strokeDownwardOffset: Double = 5.0
    @AppStorage(StrokeLineWidthKey) var strokeLineWidth: Double = 1.6
    @AppStorage(StrokeDashPaintedKey) var strokeDashPainted: Double = 1.0
    @AppStorage(StrokeDashUnPaintedKey) var strokeDashUnPainted: Double = 3.0
    var body0: some View {
        Path { path in
            path.move(to: CGPoint(
                x: box.0.x * geometrySize.width,
                y: (1 - box.1.y) * geometrySize.height + CGFloat(strokeDownwardOffset)))
            path.addLine(to: CGPoint(
                x: box.1.x * geometrySize.width,
                y: (1 - box.1.y) * geometrySize.height + CGFloat(strokeDownwardOffset)))
        }
        .stroke(
            hlColor,
            style: StrokeStyle(
                lineWidth: CGFloat(strokeLineWidth),
                lineCap: .round,
                //                lineJoin: .miter,
                //                miterLimit: 0,
                dash: [CGFloat(strokeDashPainted), CGFloat(strokeDashUnPainted)]
                //                dashPhase: 0
            )
        )
    }
    
    var w: CGFloat {
        abs(box.1.x - box.0.x) * geometrySize.width
    }
    var h: CGFloat {
        abs(box.1.y - box.0.y) * geometrySize.height
    }
    
    @AppStorage(IsShowIndexKey) var isShowIndex: Bool = false
    @AppStorage(IndexColorKey) var indexColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(IndexXBasicKey) var indexXBasic: Int = IndexXBasic.trailing.rawValue
    var x: CGFloat {
        let basicX: CGFloat = {
            switch IndexXBasic(rawValue: indexXBasic)! {
            case .leading:
                return box.0.x * geometrySize.width
            case .center:
                return (box.0.x + 0.5 * abs(box.1.x - box.0.x)) * geometrySize.width
            case .trailing:
                return box.1.x * geometrySize.width
            }
        }()
        return basicX
    }
    var y: CGFloat {
        (1 - box.1.y) * geometrySize.height + CGFloat(strokeDownwardOffset)
    }

    @AppStorage(FontNameKey) var fontName: String = defaultFontName
    @AppStorage(IndexFontSizeKey) var indexFontSize: Int = 5
    var indexFont: Font {
        Font.custom(fontName, size: CGFloat(indexFontSize))
    }
    
    @AppStorage(IndexBgColorKey) var indexBgColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(IndexPaddingKey) var indexPadding: Double = 1.5
    
    var body: some View {
        if isShowIndex {
            ZStack {
                body0

                Text(String(index))
                    .font(indexFont)
                    .padding(indexPadding)
                    .foregroundColor(Color(dataToColor(indexColor)!))
                    .background(Circle().fill(Color(dataToColor(indexBgColor)!)))
                    .shadow(radius: 3)
                    .position(x: x, y: y)
            }
        } else {
            body0
        }
    }
}

private struct HLRectangleView: View {
    let index: Int
    let box: ((CGPoint, CGPoint)) // topLeft, bottomRight, (x, y) all are decimal fraction
    let geometrySize: CGSize
    
    @AppStorage(HLRectangleColorKey) var hlRectangleColor: Data = HLRectangleColorDefault
    
    var hlColor: Color {
        Color(dataToColor(hlRectangleColor)!)
    }
    
    var body: some View {
        Rectangle()
            .path(in: {
                let rect = CGRect(
                    x: box.0.x * geometrySize.width,
                    y: (1 - box.0.y) * geometrySize.height, // notice here 1-y
                    width: abs(box.1.x - box.0.x) * geometrySize.width,
                    height: abs(box.1.y - box.0.y) * geometrySize.height
                )
                return rect
            }())
            .fill(hlColor)
    }
}

struct CropperViewWithHighlight: View {
    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    @EnvironmentObject var hlBox: HLBox
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                CropperView()
                
                switch HighlightMode(rawValue: highlightMode)! {
                case .dotted:
                    ForEach(hlBox.indexedBoxes) { b in
                        HLDottedView(index: b.index, box: b.box, geometrySize: geometry.size)
                    }
                case .rectangle:
                    ForEach(hlBox.indexedBoxes) { b in
                        HLRectangleView(index: b.index, box: b.box, geometrySize: geometry.size)
                    }
                case .disabled:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct CropperView_Previews: PreviewProvider {
    static var previews: some View {
        CropperViewWithHighlight()
            .frame(width: 1087, height: 282)
            .environmentObject(
                HLBox(indexedBoxes: [
                    IndexedBox(
                        box: (
                            CGPoint(x: 0.026194852941176485, y: 0.9134275618374559),
                            CGPoint(x: 0.15073529411764705, y: 0.7773851590106007)
                        ),
                        index: 1),
                    IndexedBox(
                        box: (
                            CGPoint(x: 0.024356617647058848, y: 0.686643109540636),
                            CGPoint(x: 0.3795955882352941, y: 0.5512367491166077)
                        ),
                        index: 2),
                    IndexedBox(
                        box: (
                            CGPoint(x: 0.124356617647058848, y: 0.646643109540636),
                            CGPoint(x: 0.4795955882352941, y: 0.5212367491166077)
                        ),
                        index: 4),
                    IndexedBox(
                        box: (
                            CGPoint(x: 0.02435661764705881, y: 0.12367491166077738),
                            CGPoint(x: 0.17325367647058823, y: 0.04770318021201414)
                        ),
                        index: 15),
                    IndexedBox(
                        box: (
                            CGPoint(x: 0.7527573529411765, y: 0.12367491166077738),
                            CGPoint(x: 0.7936580882352942, y: 0.04770318021201414)
                        ),
                        index: 3)
                ])
            )
    }
}
