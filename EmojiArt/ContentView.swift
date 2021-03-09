//
//  ContentView.swift
//  EmojiArt
//
//  Created by momo on 2021/3/8.
//

import SwiftUI

struct ContentView: View {

    private let defaultEmojiSize: CGFloat = 40

    @ObservedObject var document: EmojiArtDocument

    var body: some View {
        VStack {
            emojisView()
            GeometryReader { geometry in
                Rectangle().foregroundColor(.white).overlay(Group {
                    if document.backgroundImage != nil {
                        Image(uiImage: document.backgroundImage!).resizable().aspectRatio(contentMode: ContentMode.fit)
                    }
                }).onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    return drop(providers: providers, at: location)
                }.edgesIgnoringSafeArea([Edge.Set.bottom, .horizontal])

                ForEach(self.document.emojis) { emoji in
                    Text(emoji.text).position(position(for: emoji, in: geometry.size)).font(Font.system(size: emoji.fontSize))
                }
            }
        }
    }

    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        return CGPoint(x: emoji.location.x + size.width / 2, y: emoji.location.y + size.height / 2)
    }

    private func emojisView() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                    Text(emoji).font(Font.system(size: defaultEmojiSize)).onDrag {
                        NSItemProvider(object: emoji as NSString)
                    }
                }
            }
        }.padding(Edge.Set.horizontal)
    }


    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }

}
