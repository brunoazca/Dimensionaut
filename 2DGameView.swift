//
//  BlockGame.swift
//  PlaygroundV1
//
//  Created by Bruno Azambuja Carvalho on 27/01/24.
//
import SwiftUI
import SpriteKit
import Foundation

var spriteView2: TwoDGameScene?

struct TwoDGameView: View {
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
        spriteView2 = spriteView2 ?? TwoDGameScene(size: size, appRouter: appRouter)
        spriteView2?.size = size
        spriteView2?.scaleMode = .aspectFill
        spriteView2?.anchorPoint = .init(x:0.5, y:0.5)
        return spriteView2!
    }
}
