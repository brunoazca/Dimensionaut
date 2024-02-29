//
//  BlockGame.swift
//  PlaygroundV1
//
//  Created by Bruno Azambuja Carvalho on 27/01/24.
//
import SwiftUI
import SpriteKit
import Foundation

var spriteView: BlockGameSceneV2?

struct BlockGameView: View {
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        VStack {
            GeometryReader{ geo in
                SpriteView(scene: scene(size:geo.size))
                    .ignoresSafeArea()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func scene(size:CGSize)->SKScene{
        spriteView = spriteView ?? BlockGameSceneV2(size: size, appRouter: appRouter)
        spriteView?.size = size
        spriteView?.scaleMode = .aspectFill
        spriteView?.anchorPoint = .init(x:0.5, y:0.5)
        return spriteView!
    }
}

