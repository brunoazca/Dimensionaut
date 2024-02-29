//
//  ARViewControllerRepresentable.swift
//  ARKit-101
//
//  Created by Ricardo Venieris on 27/01/24.
//

import SwiftUI
import UIKit

struct StartViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:StartViewController
    
    init(size:CGSize, appRouter: AppRouter) {
        viewController = StartViewController(size: size, appRouter: appRouter)
    }
    
    func makeUIViewController(context: Context) -> StartViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: StartViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = StartViewController
    
    
}
