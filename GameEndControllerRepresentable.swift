//
//  ARViewControllerRepresentable.swift
//  ARKit-101
//
//  Created by Ricardo Venieris on 27/01/24.
//

import SwiftUI
import UIKit

struct GameEndControllerRepresentable: UIViewControllerRepresentable{
    let viewController:GameEndController
    
    init(size:CGSize, appRouter: AppRouter) {
        viewController = GameEndController(size: size, appRouter: appRouter)
    }
    
    func makeUIViewController(context: Context) -> GameEndController {
        return viewController
    }
    
    func updateUIViewController(_ GameEndController: GameEndController, context: Context) {
        
    }
    
    typealias UIViewControllerType = GameEndController
    
    
}
