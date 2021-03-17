//
//  ContentView.swift
//  EmojiArt
//
//  Created by momo on 2021/3/8.
//

import SwiftUI

struct ContentView: View {

    private let defaultEmojiSize: CGFloat = 40

    @ObservedObject var document: EmojiArtViewModel

    var body: some View {
        VStack {
            emojisView()
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(Group {
                        OptionalImage(uiImage: document.backgroundImage).scaleEffect(zoomScale)
                    }).gesture(doubleTabToZoom(in: geometry.size))
                    ForEach(self.document.emojis) {
                        Text($0.text).position(position(for: $0, in: geometry.size))
                            .font(animtableWithSize: $0.fontSize * zoomScale)
                    }
                }.gesture(zoomGesture())
                    .edgesIgnoringSafeArea([Edge.Set.bottom, .horizontal])
                    .clipped()
                    .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return drop(providers: providers, at: location)
                }
            }
        }
    }

    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0

    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }

    private func zoomGesture() -> some Gesture {
        //$ : property delegate
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, ourGestureStateInOut, transaction in
            ourGestureStateInOut = latestGestureScale
        }.onEnded { finalGestureScale in
            steadyStateZoomScale *= finalGestureScale
        }
    }

    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }

    private func doubleTabToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation {
                zoomToFit(document.backgroundImage, in: size)
            }
        }
    }

    private func font(for emoji: EmojiArt.Emoji) -> Font {
        return Font.system(size: emoji.fontSize * zoomScale)
    }

    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
        return location
    }

    private func emojisView() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(EmojiArtViewModel.palette.map { String($0) }, id: \.self) { emoji in
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
