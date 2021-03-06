//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by momo on 2021/3/8.
//

import SwiftUI

class EmojiArtViewModel: ObservableObject {
    private static let keyForEmoji = "emoji_untitled"
    static let palette: String = "🍏🍐🍋🍉🍇🍒🍑🍅"

    @Published private var emojiArt: EmojiArt = EmojiArt() {
        didSet {
            print("json: \(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtViewModel.keyForEmoji)
        }
    }
    @Published private(set) var backgroundImage: UIImage?

    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtViewModel.keyForEmoji)) ?? EmojiArt()
        fetchBackgroundImageData()
    }

    var emojis: [EmojiArt.Emoji] {
        emojiArt.emojis
    }

    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }

    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(where: { $0.id == emoji.id }) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }

    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(where: { $0.id == emoji.id }) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }

    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }

    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if self.emojiArt.backgroundURL == url {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
