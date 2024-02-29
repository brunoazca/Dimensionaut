//
//  GameViewController.swift
//  MeuPrimeiroGame3D
//
//  Created by Ricardo Venieris on 25/01/23.
//

import UIKit
import QuartzCore
import SceneKit
import SwiftUI

class IntroViewController: UIViewController, SCNPhysicsContactDelegate {
@ObservedObject var appRouter: AppRouter
        // create a new scene
    let scene = SCNScene(named: "IntroScene.scn")!
    let scnView:SCNView
    var meText = 0
    var passEnable = false
    init(size: CGSize, appRouter: AppRouter) {
        self.scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        self.appRouter = appRouter
        
        super.init(nibName: nil, bundle: nil)
        self.view = self.scnView
        
        scnView.allowsCameraControl = false
        
            // show statistics such as fps and timing information
        scnView.showsStatistics = false
    //        scnView.debugOptions = [.showPhysicsShapes]
        
            // configure the view
        scnView.backgroundColor = UIColor.black
        
            // set the scene to the view
        scnView.scene = scene
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var cameraNode:SCNNode = {
            // create and add a camera to the scene
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        return cameraNode
    }()


    let lightNode:SCNNode = {
            // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .ambient
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        return lightNode
        
    }()

    let ambientLightNode:SCNNode = {
            // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        return ambientLightNode
    }()


    lazy var floor: SCNNode = {
        floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
        return floor
    }()

        
    lazy var textBubble: SCNNode = {
        textBubble = scene.rootNode.childNode(withName: "textBubble", recursively: true)!
        return textBubble
    }()
        
    lazy var text1: SCNNode = {
        text1 = scene.rootNode.childNode(withName: "text1", recursively: true)!
        return text1
    }()
    
    lazy var text2: SCNNode = {
        text2 = scene.rootNode.childNode(withName: "text2", recursively: true)!
        return text2
    }()

    lazy var text3: SCNNode = {
        text3 = scene.rootNode.childNode(withName: "text3", recursively: true)!
        return text3
    }()
    
    lazy var text4: SCNNode = {
        text4 = scene.rootNode.childNode(withName: "text4", recursively: true)!
        return text4
    }()
    
    lazy var me: SCNNode = {
        me = scene.rootNode.childNode(withName: "me", recursively: true)!
        return me
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scene.physicsWorld.contactDelegate = self
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        self.textBubble.opacity = 0
        self.text1.opacity = 0
        self.text2.opacity = 0
        self.text3.opacity = 0
        self.text4.opacity = 0
        me.runAction(SCNAction.sequence([SCNAction.wait(duration: 2),SCNAction.run{_ in
            self.nextText()
            self.passEnable = true
        }]))
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
                swipeUpGesture.direction = .up
                view.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
                swipeDownGesture.direction = .down
                view.addGestureRecognizer(swipeDownGesture)
        

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if passEnable{
            nextText()
        }
    }

    func nextText(){
        meText+=1
        switch meText{
        case 1:
            textBubble.opacity = 1
            text1.opacity = 1
        case 2:
            text1.physicsBody?.isAffectedByGravity = true
            text1.physicsBody?.applyForce(SCNVector3(-1, 1, 1), asImpulse: true)
            text2.opacity = 1
        case 3:
            text2.physicsBody?.isAffectedByGravity = true
            text2.physicsBody?.applyForce(SCNVector3(-1, 1, 1), asImpulse: true)
            text3.opacity = 1
        case 4:
            text3.physicsBody?.isAffectedByGravity = true
            text3.physicsBody?.applyForce(SCNVector3(-1, 1, 1), asImpulse: true)
            text4.opacity = 1
        case 5:
            appRouter.router = .oneDTutorialView
        default:
            return
        }
    }
    @objc func handleSwipeDown(){
            
        }
    @objc func handleSwipeUp(){
                
        }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
#Preview {
    IntroView(appRouter: AppRouter())
}
