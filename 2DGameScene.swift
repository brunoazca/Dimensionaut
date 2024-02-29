//
//  GameScene.swift
//  PlaygroundV1
//
//  Created by Bruno Azambuja Carvalho on 25/01/24.
//

import Foundation
import SpriteKit
import SwiftUI

class TwoDGameScene: SKScene, SKPhysicsContactDelegate {
    @ObservedObject var appRouter: AppRouter
    var isJumping = false
    var canJump = true
    var g = -9.8
    var oneDimension = false
    var dimensionTutorial = false
    var canChangeDimension = false
    var noPlatform = false
    private var swipeUpGesture: UISwipeGestureRecognizer!

    init(size: CGSize, appRouter: AppRouter) {
        self.appRouter = appRouter
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var initialBody = SKPhysicsBody()
    var rotating = false
    var oneDPos = 0.0
    var originalSize = CGSize()

    lazy var me: SKSpriteNode = {
        let me = SKSpriteNode(texture: SKTexture(imageNamed: "2DBoy"))
        me.position.x = self.frame.minX + me.frame.width * 1.5
        me.position.y = 3
        me.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: me.frame.width, height: me.frame.height))
        originalSize = CGSize(width: me.frame.width, height: me.frame.height)
        initialBody = SKPhysicsBody(rectangleOf: CGSize(width: me.frame.width, height: me.frame.height))
        me.physicsBody?.affectedByGravity = true
        me.physicsBody?.categoryBitMask = 1
        me.physicsBody?.contactTestBitMask = 10000
        me.physicsBody?.collisionBitMask = 11010
        me.xScale = 1
        me.yScale = 1
        addChild(me)
        return me
    }()
    
    var platformCount = 0
    var platformSpeed = 7.0
    
    var platform: SKSpriteNode {
        let platformSize = Int.random(in: 400...900)
        let filled = Int.random(in: 0...1)
        let YPosition = CGFloat.random(in: self.frame.minY...self.frame.maxY/2)

        let platform = SKSpriteNode(color: .brown, size: CGSize(width: platformSize, height: filled == 0 ? 70 : Int(YPosition) + Int(self.frame.height)/2))
        
        platform.position.x = self.frame.maxX + platform.frame.width
        
        platform.position.y = YPosition
        
        if filled == 1{
            platform.position.y -= CGFloat(Int(YPosition) + Int(self.frame.height)/2)/2
        }
    
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platformSize, height: Int(platform.frame.height)))
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = 10
        platform.physicsBody?.contactTestBitMask = 1
        platform.physicsBody?.collisionBitMask = 0
        
        let move = SKAction.moveTo(x: self.frame.minX - platform.frame.width, duration: platformSpeed)
        
        platform.run(SKAction.sequence([move,SKAction.removeFromParent()]))
        
        platformIncreaseCount()
        return platform
    }
    
    var upperBarrier: SKSpriteNode {
        let upperBarrier = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width, height: self.frame.height))
        upperBarrier.zPosition = -.infinity
        upperBarrier.position.x = 0
        upperBarrier.position.y = self.frame.maxY + me.position.y + 30
        upperBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height - me.frame.height))
        upperBarrier.physicsBody?.affectedByGravity = false
        upperBarrier.physicsBody?.categoryBitMask = 10000
        upperBarrier.physicsBody?.contactTestBitMask = 0
        upperBarrier.physicsBody?.collisionBitMask = 0
        upperBarrier.alpha = 0.8
        upperBarrier.zPosition = 10
        
        return upperBarrier
    }
    
    var lowerBarrier: SKSpriteNode {
        let lowerBarrier = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width, height: self.frame.height))
        lowerBarrier.zPosition = -.infinity
        lowerBarrier.position.x = 0
        lowerBarrier.position.y = self.frame.minY + me.position.y - 75
        lowerBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height - me.frame.height))
        lowerBarrier.physicsBody?.affectedByGravity = false
        lowerBarrier.physicsBody?.categoryBitMask = 10000
        lowerBarrier.physicsBody?.contactTestBitMask = 0
        lowerBarrier.physicsBody?.collisionBitMask = 0
        lowerBarrier.alpha = 0.8
        lowerBarrier.zPosition = 10
        
        return lowerBarrier
    }
    
    var barrierEnemy: SKSpriteNode {
        let barriers = SKSpriteNode()
        
        var barrierHolePos: CGFloat = 0
        if dimensionTutorial{
            barrierHolePos = -95
        } else{
            barrierHolePos = 100
        }
        
        
        let upperBarrier = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width, height: self.frame.height))
        
        upperBarrier.position.x = self.frame.maxX*2
        upperBarrier.position.y = self.frame.maxY + barrierHolePos + 100
        upperBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height))
        upperBarrier.physicsBody?.affectedByGravity = false
        upperBarrier.physicsBody?.categoryBitMask = 10
        upperBarrier.physicsBody?.contactTestBitMask = 0
        upperBarrier.physicsBody?.collisionBitMask = 0
        
        let lowerBarrier = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width, height: self.frame.height))
        
        lowerBarrier.position.x = self.frame.maxX*2
        lowerBarrier.position.y = self.frame.minY + barrierHolePos - 100
        lowerBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height))
        lowerBarrier.physicsBody?.affectedByGravity = false
        lowerBarrier.physicsBody?.categoryBitMask = 10
        lowerBarrier.physicsBody?.contactTestBitMask = 0
        lowerBarrier.physicsBody?.collisionBitMask = 0
        
        let move = SKAction.moveTo(x: self.frame.minX*4 - barriers.frame.width, duration: 6)
        
        barriers.run(SKAction.sequence([SKAction.wait(forDuration: 3),move,SKAction.removeFromParent()]))
        barriers.run(SKAction.sequence([SKAction.wait(forDuration: 6),
                                        SKAction.run{ [self] in
 
                if !self.dimensionTutorial{
                    self.platformGame = true
                    self.addChild(self.platform)
                }
            },SKAction.wait(forDuration: 3),
                                        SKAction.run{ [self] in
                self.platformGame = true
                self.addChild(self.platform)
                if self.dimensionTutorial{
                        textBubble(text1: "Keep swiping down", text2: "to change dimensions!", node: me)
                    }
                self.dimensionTutorial = false
            }]))
        barriers.addChild(upperBarrier)
        barriers.addChild(lowerBarrier)
        
        return barriers
    }
    
    lazy var startFloor: SKSpriteNode = {
        startFloor = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width*2, height: self.frame.height - 50))
        
        startFloor.position.x = 0
        startFloor.position.y = self.frame.minY
        startFloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: startFloor.frame.width, height: startFloor.frame.height))
        
        startFloor.physicsBody?.affectedByGravity = false
        startFloor.physicsBody?.categoryBitMask = 10000
        startFloor.physicsBody?.contactTestBitMask = 1
        startFloor.physicsBody?.collisionBitMask = 0
        
        addChild(startFloor)
        
        let move = SKAction.moveTo(x: self.frame.minX - startFloor.frame.width, duration: 8)
        
        startFloor.run(SKAction.sequence([SKAction.wait(forDuration: 3) ,move, SKAction.removeFromParent()]))
        
        return startFloor
    }()
    
    lazy var startPlatform: SKSpriteNode = {
        startPlatform = SKSpriteNode(color: .brown, size: CGSize(width: 600, height: 100))
        
        startPlatform.position.x = 0
        startPlatform.position.y = 25

        startPlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 600, height: 100))
        startPlatform.physicsBody?.affectedByGravity = false
        startPlatform.physicsBody?.categoryBitMask = 10
        startPlatform.physicsBody?.contactTestBitMask = 1
        startPlatform.physicsBody?.collisionBitMask = 0
        
        let move = SKAction.moveTo(x: self.frame.minX - startPlatform.frame.width, duration: 4)
        addChild(startPlatform)
        startPlatform.run(SKAction.sequence([SKAction.wait(forDuration: 4) ,SKAction.run {
            self.platformTimer.fire()
            self.platformGame = true
        },SKAction.wait(forDuration: 2),move,SKAction.removeFromParent()]))
        return startPlatform
    }()
    
    var finalPlatform: SKSpriteNode {
        let finalPlatform = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width*7, height: self.frame.height/2))
        
        finalPlatform.position.x = self.frame.maxX + finalPlatform.frame.width
        finalPlatform.position.y = self.frame.minY
        
        finalPlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: finalPlatform.frame.width, height: finalPlatform.frame.height))
        
        finalPlatform.physicsBody?.affectedByGravity = false
        finalPlatform.physicsBody?.categoryBitMask = 1000
        finalPlatform.physicsBody?.contactTestBitMask = 0
        finalPlatform.physicsBody?.collisionBitMask = 0
        
        let move = SKAction.moveTo(x: self.frame.minX + finalPlatform.frame.width/2, duration: 6)
        finalPlatform.run(SKAction.sequence([move, SKAction.wait(forDuration: 12), SKAction.moveTo(x: self.frame.minX - finalPlatform.frame.width/2, duration: 6)]))
        finalPlatform.run(SKAction.sequence([SKAction.wait(forDuration: 4),  SKAction.run {
            if !self.dimensionTutorial{
                print(self.finalBarrier)
            }
        }]))
        return finalPlatform
    }
    
    lazy var finalBarrier: SKSpriteNode = {
        finalBarrier = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width, height: self.frame.height))
        
        finalBarrier.position.x = self.frame.maxX + finalBarrier.frame.width
        finalBarrier.position.y = 0
        
        finalBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: finalBarrier.frame.width, height: finalBarrier.frame.height))
        
        finalBarrier.physicsBody?.affectedByGravity = false
        finalBarrier.physicsBody?.categoryBitMask = 1000
        finalBarrier.physicsBody?.contactTestBitMask = 0
        finalBarrier.physicsBody?.collisionBitMask = 0
        
        let move = SKAction.moveTo(x: self.frame.minX + self.finalBarrier.frame.width/2 + self.frame.width/4, duration: 4)
        finalBarrier.run(SKAction.sequence([move, SKAction.run{
            self.textBubble(text1: "This wall won't stop me!", text2: "LET'S GO 3D!!!", node: self.me)
            self.addChild(self.finalPlatform)
        },SKAction.wait(forDuration: 3), SKAction.run{
            self.appRouter.router = .threeDTutorialView
        }]))
        finalBarrier.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 1),SKAction.run {
            self.platformGame = false
        }])))
        addChild(finalBarrier)
        
        return finalBarrier
    }()
    
    var platformGame = false
    var platformTimerSpeed = Float.random(in: 1.5...2.5)
    
    lazy var platformTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(platformTimerSpeed), repeats: true, block: { _ in
        self.addChild(self.platform)
        self.updateTimer()
    })
    
    func updateTimer() {
        platformTimerSpeed = Float.random(in: 1.5...2.5)
        platformTimer.invalidate()
        platformTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(platformTimerSpeed), repeats: true) { [weak self] _ in
            if self?.platformGame == true && self?.noPlatform == false{
                self?.addChild(self?.platform ?? SKSpriteNode())
                self?.updateTimer()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        print(startFloor)
        print(startPlatform)
        textBubble(text1: "My 2D Body! Make", text2: "me jump on the platforms!", node: me)
        physicsWorld.gravity = CGVector(dx: 0, dy: 2*g)
        self.physicsWorld.contactDelegate = self
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
                swipeUpGesture.direction = .up
                view.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if me.position.x <= self.frame.minX - me.frame.width/2 || me.position.x >= self.frame.maxX + me.frame.width/2 {
            if oneDimension{
                changeDimension()
            }
            me.position.x = 0
            me.position.y = self.frame.maxY*2
            me.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
        if !oneDimension{
            if me.position.y <= self.frame.minY{
                me.position.y = self.frame.maxY*2
                me.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
            if me.zRotation >= 0.5 || me.zRotation <= -0.5 {
                if !rotating{
                    playerRotateBack()
                }
            }
        } else{
            if me.zRotation != 0 {
                me.zRotation = 0
            }
            if me.position.y != oneDPos{
                me.position.y = oneDPos
            }
        }
    }
    
    func playerRotateBack(){
        if !oneDimension{
            rotating = true
            let rotateAction = SKAction.rotate(toAngle: CGFloat(0), duration: 0.5)
            me.run(SKAction.sequence([SKAction.wait(forDuration: 1) ,SKAction.run{
                if (self.me.zRotation > 0.5 || self.me.zRotation < -0.5) && self.canJump {
                    self.me.run(rotateAction)
                }
            }, SKAction.wait(forDuration: 1) ,SKAction.run{
                self.rotating = false
                return
            }]))
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = touches.first!.location(in: self)
        if position.x <= me.position.x - 10 && me.position.x >= -self.frame.width/2 + 120{
            me.run(SKAction.moveTo(x: me.position.x - 50, duration: 0.1))
        } else if position.x > me.position.x + 10 && me.position.x <= self.frame.width/2 - 140{
            me.run(SKAction.moveTo(x: me.position.x + 50, duration: 0.1))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = touches.first!.location(in: self)
        if position.x <= me.position.x - 10 && me.position.x >= -self.frame.width/2 + 120{
            me.run(SKAction.moveTo(x: me.position.x - 10, duration: 0))
        } else if position.x > me.position.x + 10 && me.position.x <= self.frame.width/2 - 140{
            me.run(SKAction.moveTo(x: me.position.x + 10, duration: 0))
        }
    }
    
    @objc func handleSwipeUp() {
        if !oneDimension{
            if !isJumping && canJump{
            me.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2000))
                isJumping = true
            }
        }
    }
    
    @objc func handleSwipeDown() {
        changeDimension()
    }
        
    func changeDimension(){
        if canChangeDimension{
            if me.position.y > self.frame.minY && me.position.y < self.frame.maxY{
                if !oneDimension{
                    oneDimension = true
                    oneDPos = me.position.y
                    me.texture = SKTexture(imageNamed: "BlueBlock")
                    me.size = CGSize(width: 110, height: 110)
                    me.position.y += 25
                    me.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100), center: CGPoint(x: 0, y: -25))
                    me.physicsBody?.affectedByGravity = false
                    me.physicsBody?.categoryBitMask = 1
                    me.physicsBody?.contactTestBitMask = 10000
                    me.physicsBody?.collisionBitMask = 10010
                    me.run(SKAction.rotate(toAngle: CGFloat(0), duration: 0.1))
                    me.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    addChild(upperBarrier)
                    addChild(lowerBarrier)
                    me.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.rotate(toAngle: CGFloat(0), duration: 0.1), SKAction.run{
                        self.me.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    }]))
                } else{
                    oneDimension = false
                    isJumping = false
                    canJump = true
                    me.size = originalSize
                    me.texture = SKTexture(imageNamed: "2DBoy")
                    me.physicsBody = initialBody
                    me.physicsBody?.categoryBitMask = 1
                    me.physicsBody?.contactTestBitMask = 10000
                    me.physicsBody?.collisionBitMask = 10010
                    me.physicsBody?.affectedByGravity = true
                    me.run(SKAction.rotate(toAngle: CGFloat(0), duration: 0.1))
                    me.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    for node in self.children{
                        if node.physicsBody?.categoryBitMask == 10000{
                            node.removeFromParent()
                        }
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == 1 || contact.bodyB.categoryBitMask == 1 {
            isJumping = false
            canJump = true
        }
    }
    
    func platformIncreaseCount(){
        platformCount += 1
        if platformCount == 5{
            changeDimensionTutorial()
        }
        if platformCount == 7{
            platformGame = false
            addChild(barrierEnemy)
        }
        if platformCount == 10{
            noPlatform = true
            platformGame = false
            addChild(finalPlatform)
        }
    }
    
    func changeDimensionTutorial(){
        dimensionTutorial = true
        addChild(finalPlatform)
        me.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run{ [self] in
            platformGame = false
        }, SKAction.wait(forDuration: 5), SKAction.run{ [self] in
            textBubble(text1: "Pay attention to", text2: "what I say now!", node: me)
        },SKAction.wait(forDuration: 3),SKAction.run { [self] in
            textBubble(text1: "You'll need to turn 1D", text2: "to face the next obstacle!", node: me)
        },SKAction.wait(forDuration: 3),SKAction.run { [self] in
            canChangeDimension = true
            addChild(barrierEnemy)
            textBubble(text1: "SWIPE DOWN and go 1D!", text2: "Pass through that hole!", node: me)
        }]))
        
    }
    
    func textBubble(text1: String, text2: String, node: SKNode){
        let flip: Bool = node.position.x < 0
        let textBubble = SKSpriteNode(texture: SKTexture(imageNamed: "TextBubble"))
        textBubble.position = CGPoint(x: -50, y: 180)
        textBubble.size = CGSize(width: 500, height: 250)
        
        let label1 = SKLabelNode(text: text1)
        label1.fontSize = 35
        label1.fontName = "Kanit-Regular"
        label1.fontColor = .black
        label1.position = CGPoint(x: 0, y: 40)
        label1.verticalAlignmentMode = .center
        label1.horizontalAlignmentMode = .center
        
        let label2 = SKLabelNode(text: text2)
        label2.fontName = "Kanit-Regular"
        label2.fontSize = 35
        label2.fontColor = .black
        label2.position = CGPoint(x: 0, y: 0)
        label2.verticalAlignmentMode = .center
        label2.horizontalAlignmentMode = .center
        
        if flip == true {
            textBubble.xScale = -1
            label1.xScale = -1
            label2.xScale = -1
            textBubble.position = CGPoint(x: 35, y: 180)
        }
        if node.xScale < 0 {
            textBubble.xScale *= -1
            textBubble.position.x *= -1
            textBubble.xScale = 1/node.xScale
            textBubble.yScale = 1/node.yScale
        }
        if node.position.x < -self.frame.width/2 + textBubble.frame.width/3 {
            textBubble.position.x += (-me.position.x) - self.frame.width/2 + textBubble.frame.width/3
        }
        textBubble.xScale *= 0.8
        textBubble.yScale *= 0.8
        textBubble.addChild(label1)
        textBubble.addChild(label2)
        node.addChild(textBubble)
        let waitAction = SKAction.wait(forDuration: 3)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([waitAction, removeAction])
        textBubble.zPosition = 100
        textBubble.run(sequence)
    }
    
    func gameEnd(){
        platformGame = false
        print(finalPlatform)
    }
    
}

#Preview {
    TwoDGameView(appRouter: AppRouter())
}
