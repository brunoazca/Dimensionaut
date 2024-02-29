//
//  StartView.swift
//  PlaygroundV1
//
//  Created by Bruno Azambuja Carvalho on 30/01/24.
//

import SwiftUI
import SpriteKit

struct OneDTutorialView: View {
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        ZStack{
            Image("Print1D")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .brightness(-0.2)
            VStack{
                Spacer()
                Text("1-Dimensional Experience")
                    .font(.custom("Kanit-regular", size: 90))
                    .multilineTextAlignment(.center)
                    .colorInvert()
                Spacer()
                HStack{
                    Image("touch-screen")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .colorInvert()
                        .scaleEffect(x: 1, y: 1)
                    Spacer()
                    Image("touch-screen")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .colorInvert()
                        .scaleEffect(x: -1, y: 1)
                }
                .padding(.horizontal, 100.0)
                Spacer()
                Text("DRAG the finger through the screen to move in the 1D Line!")
                    .font(.custom("Kanit-regular", size: 40))
                    .multilineTextAlignment(.center)
                    .colorInvert()
                Text("Touch the screen to continue")
                    .font(.custom("Kanit-regular", size: 40))
                    .multilineTextAlignment(.center)
                    .colorInvert()
                Spacer()
            }
        }.onTapGesture {
            appRouter.router = .blockGameView
        }
        
    }
}
