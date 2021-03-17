//
//  AnimatableFontModifier.swift
//  EmojiArt
//
//  Created by momo on 2021/3/17.
//

import SwiftUI

struct AnimatableFontModifier: AnimatableModifier, ViewModifier{

    var size: CGFloat
    var weight: Font.Weight = .regular
    var design: Font.Design = .default

    func body(content: Content) -> some View {
        content.font(Font.system(size: size, weight: weight, design: design))
    }

    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }
}

extension View {
    func font(animtableWithSize size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(AnimatableFontModifier(size: size, weight: weight, design: design))
    }
}
