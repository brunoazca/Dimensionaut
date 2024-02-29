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

class ThreeDGameViewController: UIViewController, SCNPhysicsContactDelegate {
    @ObservedObject var appRouter: AppRouter
        // create a new scene
    var gravity = -30
    var jumpHeight = 23
    var speed = 0.1
    let scene = SCNScene(named: "scnScene.scn")!
    let scnView:SCNView
    var dimensionTutorialStarted = false
    var dimensionsEnable = false
    var gameEnd = false
    var finalStop = false
    
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
        cameraNode.camera = SCNCamera()
        let startPosition = SCNVector3(x: 0, y: 8, z: me.position.z - 20)
       cameraNode.transform = SCNMatrix4MakeRotation(Float.pi, 0, 1, 0)
       cameraNode.position = startPosition
        cameraNode.camera?.zFar = 1000
        
       let delay = 0.1
       let follow = SCNAction.run {node in
           var newPosition = self.me.position
            newPosition.x += startPosition.x
           newPosition.y += startPosition.y
           newPosition.z = self.cameraZTrack.position.z
           node.runAction(SCNAction.move(to: newPosition, duration: 0.1))
        }
        let wait     = SCNAction.wait(duration: 0.1)
        let sequence = SCNAction.sequence([wait,follow])
        let repeatSequence = SCNAction.repeatForever(sequence)
        cameraNode.runAction(repeatSequence)
        
        return cameraNode
    }()
    
    lazy var cameraZTrack: SCNNode = {
        let cameraZTrack = SCNNode()
        cameraZTrack.position = SCNVector3(x: 0, y: 8, z: me.position.z - 20)
        
        let runWait = SCNAction.wait(duration: 0.1)
        let runMove     = SCNAction.run { node in
            if !self.finalStop{
                node.runAction(SCNAction.moveBy(x: 0, y: 0, z: 3, duration: 0.1))
            }
        }
        
        cameraZTrack.runAction(SCNAction.sequence([SCNAction.wait(duration: 3.5), SCNAction.repeatForever(SCNAction.sequence([runWait,runMove]))]))
        
        return cameraZTrack
    }()
    let lightNode:SCNNode = {
            // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
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
    
    lazy var me: SCNNode = {
        
        me = scene.rootNode.childNode(withName: "me", recursively: true)!
        me.physicsBody?.angularVelocityFactor = SCNVector3Zero
        return me
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
    
    var torusNode:SCNNode {
            // create a 3D torus object
        let radius:CGFloat = CGFloat.random(in: 7...20)
        let torusGeometry = SCNBox(width: radius, height: radius, length: 20, chamferRadius: 1)//SCNTorus(ringRadius: radius, pipeRadius: 0.75)
        
            // apply a metallic material to the torus
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        torusGeometry.materials = [material]
        
            // create a node to hold the torus
        let torusNode = SCNNode(geometry: torusGeometry)
        torusNode.name = "torus"
        
        let physicsBodyGeometry = SCNBox(width: radius, height: radius, length: 20, chamferRadius: 0)
        let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
        let physicsBody         = SCNPhysicsBody(type: .dynamic, shape: physicsBodyShape)
        
        let physicsBodyTwoDGeometry = SCNBox(width: 60, height: radius, length: 20, chamferRadius: 0)
        let physicsBodyTwoDShape    = SCNPhysicsShape(geometry: physicsBodyTwoDGeometry)
        let physicsBodyTwoD         = SCNPhysicsBody(type: .dynamic, shape: physicsBodyTwoDShape)
        
        physicsBody.isAffectedByGravity = true
        physicsBody.categoryBitMask = 11
        physicsBody.contactTestBitMask = 11
        physicsBody.collisionBitMask = 11
        
        physicsBodyTwoD.isAffectedByGravity = true
        physicsBodyTwoD.categoryBitMask = 11
        physicsBodyTwoD.contactTestBitMask = 11
        physicsBodyTwoD.collisionBitMask = 11
        physicsBody.mass = 10000
        physicsBodyTwoD.mass = 10000
        torusNode.physicsBody = physicsBody
        
        let repeatAction = SCNAction.repeatForever(SCNAction.sequence([SCNAction.run{_ in
            if self.isTwoD == true{
                torusNode.physicsBody?.physicsShape = physicsBodyTwoDShape
            } else{
                torusNode.physicsBody?.physicsShape = physicsBodyShape
            }
        }, SCNAction.wait(duration: 0.1)]))
        
        torusNode.runAction(repeatAction)
        
            // apply a rotation matrix to the torus node
        torusNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
            // return the new torus
        return torusNode
    }
    
    var platformNodeType = 1
    var platformNode:SCNNode {
            // create a 3D torus object
        platformNodeType = Int.random(in: 1...2)
        
        var length: CGFloat = 3
        switch platformNodeType{
        case 1:
            length = 3
        case 2:
            length = 50
        default:
            length = 3
        }
        let platformGeometry = SCNBox(width: 20, height: 55, length: length, chamferRadius: 0)//SCNTorus(ringRadius: radius, pipeRadius: 0.75)
        let platformGeometryTwoD = SCNBox(width: 0, height: 55, length: length, chamferRadius: 0)//SCNTorus(ringRadius: radius, pipeRadius: 0.75)
        
            // apply a metallic material to the torus
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        material.diffuse.contents = UIColor.brown
        platformGeometry.materials = [material]
        platformGeometryTwoD.materials = [material]
        let platformNode = SCNNode(geometry: platformGeometry)
        platformNode.name = "platform"
        
        if platformNodeType == 2{
            platformNode.position.y -= 47
        }
            // create a node to hold the torus
    
        let physicsBodyGeometry = SCNBox(width: 20, height: 55, length: length, chamferRadius: 10)
        let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
        let physicsBody         = SCNPhysicsBody(type: .static, shape: physicsBodyShape)
        let physicsBodyTwoDGeometry = SCNBox(width: 100, height: 55, length: length, chamferRadius: 10)
        let physicsBodyTwoDShape = SCNPhysicsShape(geometry: physicsBodyTwoDGeometry)
        let physicsBodyTwoD = SCNPhysicsBody(type: .static, shape: physicsBodyTwoDShape)
        
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = 11
        physicsBody.contactTestBitMask = 11
        physicsBody.collisionBitMask = 11
        
        physicsBodyTwoD.isAffectedByGravity = false
        physicsBodyTwoD.categoryBitMask = 11
        physicsBodyTwoD.contactTestBitMask = 11
        physicsBodyTwoD.collisionBitMask = 11
        
        let repeatAction = SCNAction.repeatForever(SCNAction.sequence([SCNAction.run{_ in
            if self.isTwoD == true{
                platformNode.physicsBody = physicsBodyTwoD
                platformNode.geometry = platformGeometryTwoD
            } else{
                platformNode.geometry = platformGeometry
                platformNode.physicsBody = physicsBody
            }
        }, SCNAction.wait(duration: 0.1)]))
        
        platformNode.runAction(repeatAction)
        
            // apply a rotation matrix to the torus node
        platformNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
            // return the new torus
        return platformNode
    }
    
    var planeNode:SCNNode {
        let planeGeometry = SCNBox(width: 0.02, height: 55, length: 20, chamferRadius: 0)
        let planeGeometryTwoD = SCNBox(width: 0, height: 55, length: 20, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        material.diffuse.contents = UIColor.orange
        planeGeometry.materials = [material]
        planeGeometryTwoD.materials = [material]
        
            // create a node to hold the torus
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.name = "plane"
    
        let physicsBodyGeometry = SCNBox(width: 0.2, height: 55, length: 20, chamferRadius: 0)
        let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
        let physicsBody         = SCNPhysicsBody(type: .static, shape: physicsBodyShape)
        let physicsBodyTwoDGeometry = SCNBox(width: 100, height: 55, length: 20, chamferRadius: 0)
        let physicsBodyTwoDShape = SCNPhysicsShape(geometry: physicsBodyTwoDGeometry)
        let physicsBodyTwoD = SCNPhysicsBody(type: .static, shape: physicsBodyTwoDShape)
        
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = 0
        physicsBody.contactTestBitMask = 0
        physicsBody.collisionBitMask = 0
        
        physicsBodyTwoD.isAffectedByGravity = false
        physicsBodyTwoD.categoryBitMask = 11
        physicsBodyTwoD.contactTestBitMask = 11
        physicsBodyTwoD.collisionBitMask = 11
        
        let repeatAction = SCNAction.repeatForever(SCNAction.sequence([SCNAction.run{_ in
            if self.isTwoD == true{
                planeNode.physicsBody = physicsBodyTwoD
                planeNode.geometry = planeGeometryTwoD
            } else{
                planeNode.geometry = planeGeometry
                planeNode.physicsBody = physicsBody
            }
        }, SCNAction.wait(duration: 0.1)]))
        
        planeNode.runAction(repeatAction)
        
            // apply a rotation matrix to the torus node
        planeNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
            // return the new torus
        return planeNode
    }
    
    var platformBarrierNode:SCNNode {
            // create a 3D torus object

        let platformBarrierGeometry = SCNBox(width: 30, height: 55, length: 3, chamferRadius: 0)//SCNTorus(ringRadius: radius, pipeRadius: 0.75)
        let platformBarrierGeometryTwoD = SCNBox(width: 0, height: 55, length: 3, chamferRadius: 0)//SCNTorus(ringRadius: radius, pipeRadius: 0.75)
        
            // apply a metallic material to the torus
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        material.diffuse.contents = UIColor.brown
        platformBarrierGeometry.materials = [material]
        platformBarrierGeometryTwoD.materials = [material]
        
            // create a node to hold the torus
        let platformBarrierNode = SCNNode(geometry: platformBarrierGeometry)
        platformBarrierNode.name = "platformBarrier"
    
        let physicsBodyGeometry = SCNBox(width: 30, height: 55, length: 3, chamferRadius: 0)
        let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
        let physicsBody         = SCNPhysicsBody(type: .static, shape: physicsBodyShape)
        let physicsBodyTwoDGeometry = SCNBox(width: 100, height: 55, length: 3, chamferRadius: 0)
        let physicsBodyTwoDShape = SCNPhysicsShape(geometry: physicsBodyTwoDGeometry)
        let physicsBodyTwoD = SCNPhysicsBody(type: .static, shape: physicsBodyTwoDShape)
        
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = 11
        physicsBody.contactTestBitMask = 11
        physicsBody.collisionBitMask = 11
        
        physicsBodyTwoD.isAffectedByGravity = false
        physicsBodyTwoD.categoryBitMask = 11
        physicsBodyTwoD.contactTestBitMask = 11
        physicsBodyTwoD.collisionBitMask = 11
        
        
        let repeatAction = SCNAction.repeatForever(SCNAction.sequence([SCNAction.run{_ in
            if self.isTwoD == true{
                platformBarrierNode.physicsBody = physicsBodyTwoD
                platformBarrierNode.geometry = platformBarrierGeometryTwoD
            } else{
                platformBarrierNode.geometry = platformBarrierGeometry
                platformBarrierNode.physicsBody = physicsBody
            }
        }, SCNAction.wait(duration: 0.1)]))
        
        platformBarrierNode.runAction(repeatAction)
        
            // apply a rotation matrix to the torus node
        platformBarrierNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
        
    
            // return the new torus
        return platformBarrierNode
    }
    
    var floorNode:SCNNode {
        let floorGeometry = SCNBox(width: 90, height: 180, length: 30, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        material.diffuse.contents = UIColor.white
        floorGeometry.materials = [material]
        
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.name = "floorNode"
    
        let physicsBodyGeometry = SCNBox(width: 80, height: 180, length: 30, chamferRadius: 0)
        let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
        let physicsBody         = SCNPhysicsBody(type: .static, shape: physicsBodyShape)
        
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = 11
        physicsBody.contactTestBitMask = 11
        physicsBody.collisionBitMask = 11
        floorNode.physicsBody = physicsBody
        floorNode.position.x = 0
        floorNode.position.z = 1000
            // apply a rotation matrix to the torus node
        floorNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
            // return the new torus
        return floorNode
    }
    var wallNode:SCNNode {
        let floorGeometry = SCNBox(width: 90, height: 180, length: 200, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        material.diffuse.contents = UIColor.white
        floorGeometry.materials = [material]
        
        let wallNode = SCNNode(geometry: floorGeometry)
        wallNode.name = "wallNode"
    
        let physicsBodyGeometry = SCNBox(width: 80, height: 180, length: 200, chamferRadius: 0)
        let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
        let physicsBody         = SCNPhysicsBody(type: .static, shape: physicsBodyShape)
        
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = 11
        physicsBody.contactTestBitMask = 11
        physicsBody.collisionBitMask = 11
        wallNode.physicsBody = physicsBody
        wallNode.position.x = 0
        wallNode.position.z = 1000
            // apply a rotation matrix to the torus node
        wallNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
            // return the new torus
        return wallNode
    }

    lazy var platformField:SCNNode = {
        let platformField = SCNNode()
        
            // spawn action
        let wait           = SCNAction.wait(duration: 2.2)
        let spawn          = SCNAction.run {_ in self.addPlatform() }
        let sequence       = SCNAction.sequence([wait, spawn])
        let repeatSequence = SCNAction.repeatForever(sequence)
        platformField.runAction(repeatSequence)
        
        return platformField
    }()
    
    lazy var planeField:SCNNode = {
        let planeField = SCNNode()
        
            // spawn action
        let wait           = SCNAction.wait(duration: 2.2)
        let spawn          = SCNAction.run {_ in self.addPlane() }
        let sequence       = SCNAction.sequence([spawn, wait])
        let repeatSequence = SCNAction.repeatForever(sequence)
        planeField.runAction(repeatSequence)
        
        return planeField
    }()
    
    lazy var crazyField:SCNNode = {
        let platformField = SCNNode()
        
            // spawn action
        let wait           = SCNAction.wait(duration: 2.2)
        let spawn          = SCNAction.run {_ in self.addCrazyPlatform() }
        let sequence       = SCNAction.sequence([spawn, wait])
        let repeatSequence = SCNAction.repeatForever(sequence)
        platformField.runAction(repeatSequence)
        
        return platformField
    }()
    
    lazy var torusField:SCNNode = {
        let torusField = SCNNode()
        
            // spawn action
        let wait           = SCNAction.wait(duration: 1)
        let spawn          = SCNAction.run {_ in self.addTorus() }
        let sequence       = SCNAction.sequence([spawn, wait])
        let repeatSequence = SCNAction.sequence([SCNAction.wait(duration: 3.5),SCNAction.repeatForever(sequence)])
        torusField.runAction(repeatSequence)
        
        return torusField
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scene.physicsWorld.gravity = SCNVector3(0, gravity, 0)
        scene.physicsWorld.contactDelegate = self
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(torusField)
        scene.rootNode.addChildNode(cameraZTrack)
        textBubble.opacity = 1
        text1.opacity = 1
        text2.opacity = 0
        text3.opacity = 0
        text4.opacity = 0
        me.runAction(SCNAction.sequence([SCNAction.wait(duration: 3.5), SCNAction.run({ [self]_ in
            text1.opacity = 0
            textBubble.opacity = 0
        })]))
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
                swipeUpGesture.direction = .up
                view.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
                swipeDownGesture.direction = .down
                view.addGestureRecognizer(swipeDownGesture)
        
        meMovement()

    }
    
    func addTorus() {

        guard torusField.childNodes.count < 4 else {return}
            // get last torus position
        let lastTorusposition = torusField.childNodes.last?.position ?? SCNVector3(x: 0, y: 0, z: 70)
            // create a new Torus
        let newTorus = torusNode
        
            // generate a displacement distance generated in a "grid way" for left or right
        newTorus.position.x = Float.random(in: -30...30)
        newTorus.position.y = 30
            // generate a displacement distance random generated in a range
        newTorus.position.z = lastTorusposition.z + Float.random(in:  40...50)
        
        torusField.addChildNode(newTorus)
        
    }
    
    var lastNewXpos: Float = 0
    var newXPos: Float = 0
    var newYPos: Float = 0
    
    func addPlatform() {
        guard platformField.childNodes.count < 4 else {
            platformField.removeAllActions()
            let floor = floorNode
            lastNewXpos = 0
            floor.position.z = me.position.z + 1000
            platformField.addChildNode(floor)
            floor.runAction(SCNAction.move(to: SCNVector3(x: 0, y: -20, z: me.position.z + 165), duration: 0.3))
            return}
            // get last torus position
        let lastPlatformposition = platformField.childNodes.last?.position ?? SCNVector3(x: 0, y: 0, z:  me.position.z + 50)
            // create a new Torus
        let newPlatform = platformNode
        
            // generate a displacement distance generated in a "grid way" for left or right
        lastNewXpos = newXPos
        newXPos = lastPlatformposition.x + Float.random(in: -20...20)
        if newXPos >= 40 {
            newXPos = 40
        } else if newXPos <= -40{
            newXPos = -40
        }
        newPlatform.position.x = newXPos
        
        newYPos = lastPlatformposition.y + Float.random(in: -6...6)
        if newYPos <= -15 {
            newYPos = -15
        } else if newYPos >= 12{
            newYPos = 12
        }
        if platformNodeType == 2{
            newYPos -= 23
        }
        
        respawnPos = newYPos - 20
        
        let newZPos = lastPlatformposition.z + Float.random(in:  50...80)
        
        newPlatform.position.y = newYPos
        newPlatform.position.z = me.position.z + 1000
        newPlatform.runAction(SCNAction.move(to: SCNVector3(x: newXPos, y: newYPos, z: newZPos), duration: 0.3))
            // generate a displacement distance random generated in a range
        
        platformField.addChildNode(newPlatform)
        
    }
    
    var lastChallenge = false
    
    func addPlane() {
        guard planeField.childNodes.count < 3 else {
            planeField.removeAllActions()
            for node in platformField.childNodes{
                node.removeFromParentNode()
            }
            lastNewXpos = 0
            lastChallenge = true
            let floor = floorNode
            floor.position.z = me.position.z + 1000
            scene.rootNode.addChildNode(floor)
            floor.runAction(SCNAction.move(to: SCNVector3(x: 0, y: -20, z: me.position.z + 180), duration: 0.3))
            return
           }
            // get last torus position
        let lastPlatformposition = planeField.childNodes.last?.position ?? SCNVector3(x: 0, y: -5, z:  me.position.z + 50)
            // create a new Torus
        let newPlatform = planeNode
        
        lastNewXpos = newXPos
        newXPos = lastPlatformposition.x + Float.random(in: -20...20)
        if newXPos >= 40 {
            newXPos = 40
        } else if newXPos <= -40{
            newXPos = -40
        }
        newPlatform.position.x = newXPos
        
        newYPos = lastPlatformposition.y + Float.random(in: -6...6)
        if newYPos <= -15 {
            newYPos = -15
        } else if newYPos >= 12{
            newYPos = 12
        }
        newYPos -= 5
        respawnPos = newYPos - 20
        
        let newZPos = lastPlatformposition.z + Float.random(in:  50...80)
        
        newPlatform.position.y = newYPos
        newPlatform.position.z = me.position.z + 1000
        newPlatform.runAction(SCNAction.move(to: SCNVector3(x: newXPos, y: newYPos, z: newZPos), duration: 0.3))
            // generate a displacement distance random generated in a range
        
        planeField.addChildNode(newPlatform)
        
    }
    
    func addCrazyPlatform() {
        guard crazyField.childNodes.count < 7 else {
            crazyField.removeAllActions()
            let floor = floorNode
            lastNewXpos = 0
            floor.position.z = me.position.z + 1000
            scene.rootNode.addChildNode(floor)
            floor.runAction(SCNAction.move(to: SCNVector3(x: 0, y: -30, z: me.position.z + 170), duration: 0.3))
            let wall = wallNode
            wall.position.z = me.position.z + 1000
            scene.rootNode.addChildNode(wall)
            wall.runAction(SCNAction.move(to: SCNVector3(x: 0, y: -20, z: me.position.z + 330), duration: 0.3))
            gameEnd = true
            return}
            // get last torus position
        let lastPlatformposition = crazyField.childNodes.last?.position ?? SCNVector3(x: 0, y: -6, z:  me.position.z + 50)
            // create a new Torus
        let platformType = Int.random(in: 1...3)
        
        var newPlatform: SCNNode
        
        switch platformType{
        case 1:
            newPlatform = platformBarrierNode
        case 2:
            newPlatform = planeNode
        case 3:
            newPlatform = platformNode
        default:
            newPlatform = platformNode
        }
        
        lastNewXpos = newXPos
        newXPos = lastPlatformposition.x + Float.random(in: -20...20)
        if newXPos >= 40 {
            newXPos = 40
        } else if newXPos <= -40{
            newXPos = -40
        }
        newPlatform.position.x = newXPos
        
        newYPos = lastPlatformposition.y + Float.random(in: -6...6)
        if newYPos <= -15 {
            newYPos = -15
        } else if newYPos >= 12{
            newYPos = 12
        }
        if platformType == 3{
            if platformNodeType == 2{
                newYPos -= 23
            }
        }
        if platformType == 2 {
            newYPos -= 6
        }
        
        respawnPos = newYPos - 20
        let newZPos = lastPlatformposition.z + Float.random(in:  50...80)
        
        newPlatform.position.y = newYPos
        newPlatform.position.z = me.position.z + 1000
        if platformType == 1{
            let torus = torusNode
            torus.position = SCNVector3(newXPos, newYPos + 20, newZPos)
            crazyField.addChildNode(torus)
        }
        newPlatform.runAction(SCNAction.move(to: SCNVector3(x: newXPos, y: newYPos, z: newZPos), duration: 0.3))
            // generate a displacement distance random generated in a range
        
        crazyField.addChildNode(newPlatform)
        
    }
    
    func removeOldTorus() {
        for node in torusField.childNodes {
            if node.position.z < cameraNode.position.z - 35 {
                node.removeFromParentNode()
            } else {
                return // As nodes are in order, at first viewable node, quit.
            }
        }
    }
    
    func removeOldPlatform() {
        for node in platformField.childNodes {
            if node.position.z < cameraNode.position.z {
                node.removeFromParentNode()
            } else {
                return // As nodes are in order, at first viewable node, quit.
            }
        }
    }
    
    var respawnPos: Float = -50.0
    
    func meMovement() {
        let runWait = SCNAction.wait(duration: 0.1)
        let runMove     = SCNAction.run { node in
            if !self.finalStop{
                node.runAction(SCNAction.moveBy(x: 0, y: 0, z: 3, duration: 0.1))
            }
        }
        let stopRotationAction = SCNAction.run { _ in
            // Certifique-se de acessar a propriedade de maneira segura usando if let ou guard let
            if let physicsBody = self.me.physicsBody {
                // Defina a propriedade angularVelocityFactor como SCNVector3Zero
                physicsBody.angularVelocityFactor = SCNVector3Zero
            }
        }
        let runSequence = SCNAction.sequence([runWait, runMove, stopRotationAction, SCNAction.run{ [self]_ in
            if me.position.y <= respawnPos{
                meRespawn()
            }
            if isTwoD{
                if me.position.z <= cameraNode.position.z - 35{
                    meRespawn()
                    me.position.z = cameraNode.position.z
                }
            }
            else{
                if me.position.z <= cameraNode.position.z + 5{
                    meRespawn()
                    me.position.z = cameraNode.position.z + 20
                }
            }
        }])
        let runRepeat = SCNAction.repeatForever(runSequence)
        
        let startSequence = SCNAction.sequence([SCNAction.wait(duration: 3.5), runRepeat])
        me.runAction(SCNAction.sequence([SCNAction.wait(duration: 8),SCNAction.run{ _ in
            self.scene.rootNode.addChildNode(self.platformField)
            self.torusField.removeAllActions()
            }, SCNAction.wait(duration: 2),SCNAction.run{ _ in
                self.scene.rootNode.addChildNode(self.platformField)
                self.torusField.removeAllActions()
                }]))
        me.runAction(SCNAction.repeatForever(SCNAction.sequence([SCNAction.wait(duration: 1), SCNAction.run({ [self]_ in
            if !isTwoD{
                if me.position.z < cameraZTrack.position.z + 10{
                    me.runAction(SCNAction.move(to: SCNVector3(x: me.position.x, y: me.position.y, z: cameraZTrack.position.z + 20), duration: 0.2))
                }
            }
        })])))
        me.runAction(startSequence)
    }
    
    func meRespawn(){
        var yFactor:Float = 70
        if isTwoD{
            yFactor = 80
        }
        me.position.y = yFactor + self.respawnPos
        me.physicsBody?.velocity = SCNVector3(x: .zero, y: .zero, z: .zero)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: scnView)
        print(location.x)
        if Float(location.x) <= Float(self.scnView.frame.width)/2 {
            if isTwoD{
                me.runAction(SCNAction.moveBy(x: 0, y: 0, z: -3, duration: 0.1))
            }else{
                me.runAction(SCNAction.moveBy(x: 3, y: 0, z: 0, duration: 0.1))
                
            }
        } else if Float(location.x) >= Float(self.scnView.frame.width)/2{
            if isTwoD{
                me.runAction(SCNAction.moveBy(x: 0, y: 0, z: 3, duration: 0.1))
            }else{
                me.runAction(SCNAction.moveBy(x: -3, y: 0, z: 0, duration: 0.1))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: scnView)
        if Float(location.x) <= Float(self.scnView.frame.width)/2 {
            if isTwoD{
                me.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.5, duration: 0.1))
            }else{
                me.runAction(SCNAction.moveBy(x: 0.5, y: 0, z: 0, duration: 0.1))
                
            }
        } else if Float(location.x) >= Float(self.scnView.frame.width)/2{
            if isTwoD{
                me.runAction(SCNAction.moveBy(x: 0, y: 0, z: 0.5, duration: 0.1))
            }else{
                me.runAction(SCNAction.moveBy(x: -0.5, y: 0, z: 0, duration: 0.1))
            }
        }
    }
    
    @objc func handleSwipeUp() {
        me.physicsBody?.applyForce(SCNVector3(0, jumpHeight, 0), asImpulse: true)
    }
    
    var isTwoD = false
    @objc func handleSwipeDown() {
        if dimensionsEnable{
            isTwoD.toggle()
            var startPosition:SCNVector3
            
            if isTwoD{
                me.position.x = 0
                cameraNode.removeAllActions()
                floor.position.x = 10
                
                let orthographicCamera = SCNCamera()
                orthographicCamera.usesOrthographicProjection = true
                
                // Definir a escala da câmera ortográfica (ajuste conforme necessário)
                orthographicCamera.orthographicScale = 20
                
                // Atribuir a câmera ortográfica ao nó da câmera
                cameraNode.camera = orthographicCamera
                
                // Definir a posição e a orientação da câmera para a visão lateral direita
                cameraNode.position.z = me.position.z
                cameraNode.position.y = 0
                cameraNode.position.x = -50
                cameraNode.eulerAngles = SCNVector3(x: 0, y: -Float.pi / 2, z: 0)  // Orientação para a visão lateral direita
                
                startPosition = cameraNode.position
                let runWait     = SCNAction.wait(duration: 0.1)
                let runMove     = SCNAction.run { node in
                    node.runAction(SCNAction.moveBy(x: 0, y: 0, z: 3, duration: 0.1))
                }
                cameraNode.runAction(SCNAction.repeatForever(SCNAction.sequence([runMove,runWait])))
            } else{
                floor.position.x = 0
                me.position.x = lastNewXpos
                me.physicsBody?.applyForce(SCNVector3(0, 5, 0), asImpulse: true)
                cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
                cameraNode.camera = SCNCamera()
                startPosition = SCNVector3(x: 0, y: 8, z: me.position.z - 20)
                cameraNode.transform = SCNMatrix4MakeRotation(Float.pi, 0, 1, 0)
                cameraNode.position = startPosition
                cameraNode.camera?.zFar = 1000
                
                let delay = 0.1
                let follow = SCNAction.run {node in
                    var newPosition = self.me.position
                    newPosition.x += startPosition.x
                    newPosition.y += startPosition.y
                    newPosition.z = self.cameraZTrack.position.z
                    node.runAction(SCNAction.move(to: newPosition, duration: 0.1))
                }
                let wait     = SCNAction.wait(duration: 0.01)
                let sequence = SCNAction.sequence([wait,follow])
                let repeatSequence = SCNAction.repeatForever(sequence)
                cameraNode.runAction(repeatSequence)
            }
        }
    }
    
    func dimensionTutorial(){
        dimensionTutorialStarted = true
        textBubble.opacity = 1
        text2.opacity = 1
        me.runAction(SCNAction.sequence([SCNAction.wait(duration: 3.5), SCNAction.run({ [self]_ in
            textBubble.opacity = 0
            text2.opacity = 0
            dimensionsEnable = true
            scene.rootNode.addChildNode(planeField)
        })]))
    }
    
    func lastChallengeStart(){
        lastChallenge = false
        if isTwoD{
            handleSwipeDown()
        }
        dimensionsEnable = false
        textBubble.opacity = 1
        text3.opacity = 1
        me.runAction(SCNAction.sequence([SCNAction.wait(duration: 3.2), SCNAction.run{ [self]_ in
            textBubble.opacity = 0
            text3.opacity = 0
            scene.rootNode.addChildNode(crazyField)
            dimensionsEnable = true
        }]))
    }
    
    func gameEndStart(){
        gameEnd = false
        if isTwoD{
            handleSwipeDown()
        }
        dimensionsEnable = false
        me.runAction(SCNAction.sequence([SCNAction.wait(duration: 3), SCNAction.run{ [self]_ in
            finalStop = true
            text4.opacity = 1
            textBubble.opacity = 1
        }, SCNAction.wait(duration: 3), SCNAction.run{_ in 
            self.appRouter.router = .finalView
        }]))
    }
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if !dimensionTutorialStarted{
            if (contact.nodeA.name == "floorNode" && contact.nodeB.name == "me") || (contact.nodeB.name == "floorNode" && contact.nodeA.name == "me"){
                dimensionTutorial()
            }
        }
        if lastChallenge{
            if (contact.nodeA.name == "floorNode" && contact.nodeB.name == "me") || (contact.nodeB.name == "floorNode" && contact.nodeA.name == "me"){
                lastChallengeStart()
            }
        }
        if gameEnd{
            if (contact.nodeA.name == "floorNode" && contact.nodeB.name == "me") || (contact.nodeB.name == "floorNode" && contact.nodeA.name == "me"){
                gameEndStart()
            }
        }
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
    ThreeDGameView(appRouter: AppRouter())
}
