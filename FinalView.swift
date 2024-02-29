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

struct FinalView: View {
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        ZStack{
                GeometryReader { geo in
                    FinalViewControllerRepresentable(size: geo.size, appRouter: appRouter)
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Text("Touch the screen to continue")
                            .colorInvert()
                            .padding()
                            .font(.largeTitle)
                        Spacer()
                    }
                    
                }
            }.ignoresSafeArea()
        }
    }
}
#Preview {
    FinalView(appRouter: AppRouter())
}
