//
//  GameScene.swift
//  PlaygroundV1
//
//  Created by Bruno Azambuja Carvalho on 25/01/24.
//

import Foundation
import SpriteKit
import SwiftUI

class BlockGameSceneV2: SKScene, SKPhysicsContactDelegate{
    @ObservedObject var appRouter: AppRouter
    var canMoveFront = true
    init(size: CGSize, appRouter: AppRouter) {
        self.appRouter = appRouter
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var me: SKSpriteNode = {
        me = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 100))
        me.position.x = self.frame.minX + me.frame.width*3
        me.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 1))
        me.physicsBody?.affectedByGravity = false
        me.physicsBody?.categoryBitMask = 1
        me.physicsBody?.contactTestBitMask = 1010
        me.physicsBody?.collisionBitMask = 11010
        me.physicsBody?.allowsRotation = false
        addChild(me)
        return me
    }()
    
    lazy var barrier1: SKSpriteNode = {
        barrier1 = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width, height: self.frame.height - me.frame.height))
        barrier1.zPosition = -.infinity
        barrier1.position.x = 0
        barrier1.position.y = self.frame.maxY
        barrier1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height - me.frame.height))
        barrier1.physicsBody?.isDynamic = false
        barrier1.physicsBody?.affectedByGravity = false
        barrier1.physicsBody?.categoryBitMask = 10000
        barrier1.physicsBody?.contactTestBitMask = 0
        barrier1.physicsBody?.collisionBitMask = 0
        
        addChild(barrier1)
        return barrier1
    }()
    
    lazy var barrier2: SKSpriteNode = {
        barrier2 = SKSpriteNode(color: .gray, size: CGSize(width: self.frame.width, height: self.frame.height - me.frame.height))
        barrier2.zPosition = -.infinity
        barrier2.position.x = 0
        barrier2.position.y = self.frame.minY
        barrier2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height - me.frame.height))
        barrier2.physicsBody?.isDynamic = false
        barrier2.physicsBody?.affectedByGravity = false
        barrier2.physicsBody?.categoryBitMask = 10000
        barrier2.physicsBody?.contactTestBitMask = 0
        barrier2.physicsBody?.collisionBitMask = 0
        
        addChild(barrier2)
        return barrier2
    }()
    
    var blockCount = 0
    var blockGame = false
    var finalScene = false
    
    var block: SKSpriteNode {
        let blockSize = Int.random(in: 100...200)
        let block = SKSpriteNode(color: .red, size: CGSize(width: blockSize, height: 100))
        
        block.position.x = self.frame.maxX + block.frame.width
        block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: blockSize, height: 100))
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.categoryBitMask = 10
        block.physicsBody?.contactTestBitMask = 1
        block.physicsBody?.collisionBitMask = 10001
        block.physicsBody?.mass = 10000
        let move = SKAction.moveTo(x: self.frame.minX - block.frame.width, duration: blockSpeed)
        
        block.run(SKAction.sequence([move,SKAction.removeFromParent()]))
        
        lazy var reappear = SKAction.run { [self] in
            if me.position.x <= block.position.x + block.frame.width/2 && me.position.x >= block.position.x - block.frame.width/2{
                block.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), reappear]))
            }else{
                block.physicsBody?.categoryBitMask = 10
                block.alpha = 1
            }
        }
        block.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.canMoveFront = true
            block.physicsBody?.categoryBitMask = 0
            block.alpha = 0
        }, SKAction.wait(forDuration: 0.8), reappear, SKAction.wait(forDuration: 0.8)])))
        blockIncreaseCount()
        return block
    }
    
    lazy var finalBlock: SKSpriteNode = {
        finalBlock = SKSpriteNode(color: .brown, size: CGSize(width: 600, height: 100))
        
        finalBlock.position.x = self.frame.maxX + finalBlock.frame.width
        finalBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 600, height: 100))
        
        finalBlock.physicsBody?.affectedByGravity = false
        finalBlock.physicsBody?.categoryBitMask = 1000
        finalBlock.physicsBody?.contactTestBitMask = 0
        finalBlock.physicsBody?.collisionBitMask = 10001
        finalBlock.physicsBody?.mass = 10000
        
        let move = SKAction.moveTo(x: self.frame.minX + finalBlock.frame.width + 50, duration: 4.5)
        finalBlock.run(SKAction.sequence([SKAction.wait(forDuration: 1.3),move]))
        addChild(finalBlock)
        
        return finalBlock
    }()
    
    var timerSpeed = Float.random(in: 2...4)
    
    lazy var timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerSpeed), repeats: true, block: { _ in
        self.addChild(self.block)
        self.updateTimer()
    })
    
    func updateTimer() {
        timerSpeed = Float.random(in: 2...4)
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerSpeed), repeats: true) { [weak self] _ in
            if self?.blockGame == true{
                self?.addChild(self?.block ?? SKSpriteNode())
                self?.updateTimer()
            }
        }
    }
    
    var blockSpeed = 7.0
    
    lazy var speedTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerSpeed), repeats: true, block: { _ in
        self.increaseSpeed()
    })
    
    func increaseSpeed(){
        if self.blockSpeed > 3 {
            self.blockSpeed -= 0.5
        } else{
            speedTimer.invalidate()
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        print(barrier1)
        print(barrier2)
        textBubble(text1: "OH YEAH!", text2: "1st Dimension!", node: me)
        me.run(SKAction.sequence([SKAction.wait(forDuration: 3),SKAction.run { [self] in
            textBubble(text1: "Advance when the red", text2: "blocks become invisible!", node: me)
        },SKAction.wait(forDuration: 1),SKAction.run { [self] in
            blockGame = true
            timer.fire()
            speedTimer.fire()
        }]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if me.position.y != 0{
            me.position.y = 0
        }
        if me.position.x <= self.frame.minX{
            me.position.x = 0
            let sequence = (SKAction.sequence([SKAction.run { [self] in me.alpha = 0.5}, SKAction.wait(forDuration: 0.2), SKAction.run { [self] in me.alpha = 1.0}, SKAction.wait(forDuration: 0.2)]))
            me.run(SKAction.sequence([sequence,sequence]))
            canMoveFront = true
        }
        if !canMoveFront{
            me.position.x -= 3
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        if contact.bodyB.categoryBitMask == 10 || contact.bodyA.categoryBitMask == 10 || contact.bodyB.categoryBitMask == 1000 || contact.bodyA.categoryBitMask == 1000 {
            canMoveFront = false
        }
        if !finalScene{
            if contact.bodyB.categoryBitMask == 1000{
                textBubble(text1: "Oh! I can't pass",text2: "through this block.", node: me)
                finalScene = true
                sceneEnd()
            }
            if contact.bodyA.categoryBitMask == 1000{
                textBubble(text1: "Oh! I can't pass",text2: "through this block.", node: me)
                finalScene = true
                sceneEnd()
            }
        }
    }
        
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyB.categoryBitMask == 10 || contact.bodyA.categoryBitMask == 10 || contact.bodyB.categoryBitMask == 1000 || contact.bodyA.categoryBitMask == 1000{
            canMoveFront = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = touches.first!.location(in: self)
        if position.x <= me.position.x - 10 && me.position.x >= -self.frame.width/2 + 120{
            me.run(SKAction.moveTo(x: me.position.x - 50, duration: 0.1))
        } else if position.x > me.position.x + 10 && me.position.x <= self.frame.width/2 - 140{
            if canMoveFront{
                me.run(SKAction.moveTo(x: me.position.x + 50, duration: 0.1))
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = touches.first!.location(in: self)
        if position.x <= me.position.x - 10 && me.position.x >= -self.frame.width/2 + 120{
            me.run(SKAction.moveTo(x: me.position.x - 10, duration: 0))
        } else if position.x > me.position.x + 10 && me.position.x <= self.frame.width/2 - 140{
            if canMoveFront{
                me.run(SKAction.moveTo(x: me.position.x + 10, duration: 0))
            }
        }
    }
    


    func blockIncreaseCount() {
        blockCount += 1
        guard blockGame else {
            return
        }
        
        switch blockCount{
        case 6:
            blockGame = false
            print(finalBlock)
        default:
            return
        }
        
    }
    
    func textBubble(text1: String, text2: String, node: SKNode){
        let flip: Bool = node.position.x < 0
        let textBubble = SKSpriteNode(texture: SKTexture(imageNamed: "TextBubble"))
        textBubble.position = CGPoint(x: -35, y: 210)
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
            textBubble.position = CGPoint(x: 35, y: 210)
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
        textBubble.addChild(label1)
        textBubble.addChild(label2)
        node.addChild(textBubble)
        let waitAction = SKAction.wait(forDuration: 3)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([waitAction, removeAction])
        textBubble.run(sequence)
    }
    
    func sceneEnd(){
        me.run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.run{self.textBubble(text1: "I will solve this! Let's", text2: "go to 2ND DIMENSION!!", node: self.me)},SKAction.wait(forDuration: 3),SKAction.run {
            self.removeAllChildren()
            self.removeFromParent()
            self.appRouter.router = .twoDTutorialView
        }]))
    }
}
#Preview {
    BlockGameView(appRouter: AppRouter())
}
