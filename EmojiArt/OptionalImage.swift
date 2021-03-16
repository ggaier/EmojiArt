//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by momo on 2021/3/16.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?

    var body: some View {
        if let image = uiImage {
            Image(uiImage: image)
        }
    }
}
