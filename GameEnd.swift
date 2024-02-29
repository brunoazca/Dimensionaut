//
//  StartView.swift
//  PlaygroundV1
//
//  Created by Bruno Azambuja Carvalho on 30/01/24.
//

import SwiftUI
import SpriteKit
import AVKit
import AVFoundation

struct GameEnd: View {
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        ZStack{
            GeometryReader { geo in
                GameEndControllerRepresentable(size: geo.size, appRouter: appRouter)
            }.ignoresSafeArea()
        }
    }
}
#Preview {
    GameEnd(appRouter: AppRouter())
}
