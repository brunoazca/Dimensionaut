//
//  ARViewControllerRepresentable.swift
//  ARKit-101
//
//  Created by Ricardo Venieris on 27/01/24.
//

import SwiftUI
import UIKit

struct FinalViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:FinalViewController
    
    init(size:CGSize, appRouter: AppRouter) {
        viewController = FinalViewController(size: size, appRouter: appRouter)
    }
    
    func makeUIViewController(context: Context) -> FinalViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: FinalViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = FinalViewController
    
    
}
