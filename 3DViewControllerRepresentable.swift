//
//  ARViewControllerRepresentable.swift
//  ARKit-101
//
//  Created by Ricardo Venieris on 27/01/24.
//

import SwiftUI
import UIKit

struct ThreeDViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:ThreeDGameViewController
    
    init(size:CGSize, appRouter: AppRouter) {
        viewController = ThreeDGameViewController(size: size, appRouter: appRouter)
    }
    
    func makeUIViewController(context: Context) -> ThreeDGameViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ThreeDGameViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ThreeDGameViewController
    
    
}
