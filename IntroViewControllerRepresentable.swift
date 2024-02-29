//
//  ARViewControllerRepresentable.swift
//  ARKit-101
//
//  Created by Ricardo Venieris on 27/01/24.
//

import SwiftUI
import UIKit

struct IntroViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:IntroViewController
    
    init(size:CGSize, appRouter: AppRouter) {
        viewController = IntroViewController(size: size, appRouter: appRouter)
    }
    
    func makeUIViewController(context: Context) -> IntroViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: IntroViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = IntroViewController
    
    
}
