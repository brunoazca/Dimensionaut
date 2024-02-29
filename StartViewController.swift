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

class StartViewController: UIViewController, SCNPhysicsContactDelegate {
@ObservedObject var appRouter: AppRouter
    // create a new scene
let scene = SCNScene(named: "StartScene.scn")!
let scnView:SCNView

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

lazy var text: SCNNode = {
    let text = scene.rootNode.childNode(withName: "text", recursively: true)!
    return text
}()
    
lazy var start: SCNNode = {
    let start = scene.rootNode.childNode(withName: "start", recursively: true)!
    return start
}()

lazy var floor: SCNNode = {
    floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
    return floor
}()

var torusNode:SCNNode {
        // create a 3D torus object
    let radius:CGFloat = CGFloat.random(in: 0.2...1)
    let length: CGFloat = CGFloat.random(in: 0.5...1)
    let torusGeometry = SCNBox(width: radius, height: radius, length: length, chamferRadius: 0)//SCNTorus(ringRadius: radius, pipeRadius: 0.75)
    
        // apply a metallic material to the torus
    let material = SCNMaterial()
    material.lightingModel = .physicallyBased
    material.metalness.contents = 1
    material.roughness.contents = 0.2
    material.diffuse.contents = UIColor.gray
    torusGeometry.materials = [material]
    
        // create a node to hold the torus
    let torusNode = SCNNode(geometry: torusGeometry)
    torusNode.name = "torus"
    
    let physicsBodyGeometry = SCNBox(width: radius, height: radius, length: length, chamferRadius: 0)
    let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
    let physicsBody         = SCNPhysicsBody(type: .dynamic, shape: physicsBodyShape)
    
    physicsBody.restitution = 1
    physicsBody.isAffectedByGravity = true
    physicsBody.categoryBitMask = 11
    physicsBody.contactTestBitMask = 11
    physicsBody.collisionBitMask = 11
    
    torusNode.physicsBody = physicsBody
    
        // apply a rotation matrix to the torus node
    torusNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
    
        // return the new torus
    return torusNode
}

lazy var torusField:SCNNode = {
    let torusField = SCNNode()
    
        // spawn action
    let wait           = SCNAction.wait(duration: TimeInterval(Int.random(in: 2...4)))
    let spawn          = SCNAction.run {_ in self.addTorus() }
    let sequence       = SCNAction.sequence([wait, spawn])
    let repeatSequence = SCNAction.repeatForever(sequence)
    torusField.runAction(repeatSequence)
    
    return torusField
}()

func addTorus() {
    removeOldTorus()
        // get last torus position
        // create a new Torus
    let newTorus = torusNode
    
        // generate a displacement distance generated in a "grid way" for left or right
    newTorus.position.x = Float.random(in: -1...4)
    newTorus.position.y = Float.random(in: 5...7)
        // generate a displacement distance random generated in a range
    newTorus.position.z = Float.random(in: -4...2)
    
    torusField.addChildNode(newTorus)
    
}
func removeOldTorus() {
    if torusField.childNodes.count >= 3 {
        torusField.childNodes.first?.removeFromParentNode()
    } else {
        return // As nodes are in order, at first viewable node, quit.
    }
}
var ballNode:SCNNode {
        // create a 3D torus object
    let radius:CGFloat = CGFloat.random(in: 0.2...0.8)
    let ballGeometry = SCNSphere(radius: radius)
    
        // apply a metallic material to the torus
    let material = SCNMaterial()
    material.lightingModel = .physicallyBased
    material.metalness.contents = 1
    material.roughness.contents = 0.2
    material.diffuse.contents = UIColor.blue
    ballGeometry.materials = [material]
    
        // create a node to hold the torus
    let ballNode = SCNNode(geometry: ballGeometry)
    ballNode.name = "ball"
    
    let physicsBodyGeometry = SCNSphere(radius: radius)
    let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
    let physicsBody         = SCNPhysicsBody(type: .dynamic, shape: physicsBodyShape)
    
    physicsBody.restitution = 1
    physicsBody.rollingFriction = 10
    physicsBody.isAffectedByGravity = true
    physicsBody.categoryBitMask = 11
    physicsBody.contactTestBitMask = 11
    physicsBody.collisionBitMask = 11
    
    ballNode.physicsBody = physicsBody
    
        // apply a rotation matrix to the torus node
    ballNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
    
        // return the new torus
    return ballNode
}

lazy var ballField:SCNNode = {
    let ballField = SCNNode()
    
        // spawn action
    let wait           = SCNAction.wait(duration: TimeInterval(Int.random(in: 3...5)))
    let spawn          = SCNAction.run {_ in self.addBall() }
    let sequence       = SCNAction.sequence([wait, spawn])
    let repeatSequence = SCNAction.repeatForever(sequence)
    ballField.runAction(repeatSequence)
    
    return ballField
}()

func addBall() {
    removeOldBall()
       
    let newBall = ballNode
    
    let direction = Int.random(in: 0...1)
    if direction == 0{
        newBall.position.x = Float.random(in: -6 ... -4)
        newBall.physicsBody?.applyForce(SCNVector3(Float.random(in: 0.5...2.5), 0.5, 0), asImpulse: Bool(true))
    } else{
        newBall.position.x = Float.random(in: 5 ... 7)
        newBall.physicsBody?.applyForce(SCNVector3(Float.random(in: -2.5 ... -0.5), 0.5, 0), asImpulse: Bool(true))
    }
    
    newBall.position.y = 2

    newBall.position.z = Float.random(in: -3...2)
    
    ballField.addChildNode(newBall)
    
}
func removeOldBall() {
    if ballField.childNodes.count >= 3 {
        ballField.childNodes.first?.removeFromParentNode()
    } else {
        return
    }
}
    
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    scene.physicsWorld.contactDelegate = self
    scene.rootNode.addChildNode(cameraNode)
    scene.rootNode.addChildNode(lightNode)
    scene.rootNode.addChildNode(ambientLightNode)
    scene.rootNode.addChildNode(torusField)
    scene.rootNode.addChildNode(ballField)
    
    let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
            swipeUpGesture.direction = .up
            view.addGestureRecognizer(swipeUpGesture)
    
    let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
            swipeDownGesture.direction = .down
            view.addGestureRecognizer(swipeDownGesture)
    

}


@objc func handleSwipeDown(){
        
    }
@objc func handleSwipeUp(){
            
    }

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let location = touches.first?.location(in: scnView) else {return}
    print(location.y, scnView.frame.height/3)
    if location.y >= scnView.frame.maxY*2/3 && location.x >= scnView.frame.width/2 - 90 && location.x <= scnView.frame.width/2 + 90{
        start.physicsBody?.applyForce(SCNVector3(0, 0.1, -0.7), asImpulse: true)
        start.physicsBody?.isAffectedByGravity = true
        start.physicsBody?.collisionBitMask = floor.physicsBody!.categoryBitMask
        start.runAction(SCNAction.sequence([SCNAction.wait(duration: 3),SCNAction.run{_ in 
            self.appRouter.router = .introView
        }]))
    }
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
    StartView(appRouter: AppRouter())
}
