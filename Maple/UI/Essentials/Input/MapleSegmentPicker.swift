//
//  MapleSegmentPicker.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI
import AppKit

struct MapleSegmentPicker: View {
    @Environment(\.colorScheme) var colorScheme
    let options: [String]
    
    @Binding var value: Int
    @State var segmentSize: CGSize = .zero
    
    init(withOptions options: [String], andValue val: Binding<Int>) {
        self.options = options
        self._value = val
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if self.segmentSize != .zero {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(self.colorScheme == .dark ? .gray.opacity(0.2) : .white)
                    .frame(width: self.segmentSize.width, height: self.segmentSize.height)
                    .offset(x: self.computeActiveSegmentOffset(), y: 0)
                    .animation(.easeInOut(duration: 0.2), value: self.value)
            }
            HStack {
                ForEach(0..<self.options.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            self.value = index
                        }
                    }, label: {
                        Text(self.options[index])
                            .foregroundColor(index == self.value ? Color(nsColor: .labelColor) : Color(nsColor: .secondaryLabelColor))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .modifier(SizeAwareViewModifier(viewSize: self.$segmentSize))
                    }).buttonStyle(PlainButtonStyle())
                    .if(index < 9) {
                        $0.keyboardShortcut(KeyboardShortcut(KeyEquivalent(String(index + 1).first!)))
                    }
                }
            }
        }.padding(4)
        .background(Color.primary.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: self.segmentSize) { newValue in
            print("SEGMENT SIZE IS CHANGING \(newValue)")
        }
    }
    
    private func computeActiveSegmentOffset() -> CGFloat {
        return CGFloat(self.value) * (self.segmentSize.width + 8)
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
            .onPreferenceChange(SizePreferenceKey.self, perform: { if self.viewSize != $0 && $0 != .zero { self.viewSize = $0 }})
    }
}
