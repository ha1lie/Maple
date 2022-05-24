//
//  MapleSegmentPicker.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI
import AppKit

struct MapleSegmentPicker: View {
    let options: [String]
    
    @Binding var value: Int
    @State var segmentSize: CGSize = .zero
    
    init(withOptions options: [String], andValue val: Binding<Int>) {
        self.options = options
        self._value = val
    }
    
    private var activeSegmentView: AnyView {
        let isInitialized: Bool = self.segmentSize != .zero
        if !isInitialized { return AnyView(EmptyView()) }
        
        return AnyView(RoundedRectangle(cornerRadius: 12)
            .foregroundColor(Color(.darkGray))
            .shadow(color: .black.opacity(0.2), radius: 4)
            .frame(width: self.segmentSize.width, height: self.segmentSize.height)
            .offset(x: self.computeActiveSegmentOffset(), y: 0)
            .animation(.easeInOut(duration: 0.2), value: self.value))
    }
    
    var body: some View {
        ZStack {
            self.activeSegmentView
            HStack {
                ForEach(0..<self.options.count, id: \.self) { index in
                    self.getOptionLabel(forIndex: index)
                }
            }
        }.padding(4)
        .background(Color(.darkGray).opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func computeActiveSegmentOffset() -> CGFloat {
        return CGFloat(self.value - 1) * (self.segmentSize.width + 6)
    }
    
    private func getOptionLabel(forIndex i: Int) -> some View {
        let isSelected = i == self.value
        return Button(action: {
            self.value = i
        }, label: {
            Text(self.options[i])
                .foregroundColor(isSelected ? Color(nsColor: .labelColor) : Color(nsColor: .secondaryLabelColor))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .frame(minWidth: 0, maxWidth: .infinity)
                .modifier(SizeAwareViewModifier(viewSize: self.$segmentSize))
        }).buttonStyle(PlainButtonStyle())
        .if(i < 9) {
            $0.keyboardShortcut(KeyboardShortcut(KeyEquivalent(String(i + 1).first!)))
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct BackgroundGeometryReader: View {
    var body: some View {
        GeometryReader { geo in
            return Color.clear
                .preference(key: SizePreferenceKey.self, value: geo.size)
        }
    }
}

struct SizeAwareViewModifier: ViewModifier {
    @Binding private var viewSize: CGSize
    
    init(viewSize: Binding<CGSize>) {
        self._viewSize = viewSize
    }
    
    func body(content: Content) -> some View {
        content.background(BackgroundGeometryReader())
            .onPreferenceChange(SizePreferenceKey.self, perform: { if self.viewSize != $0 { self.viewSize = $0 }})
    }
}
