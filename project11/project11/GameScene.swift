//
//  GameScene.swift
//  project11
//
//  Created by nikita on 31.01.2023.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var endGameLabel: SKLabelNode!
    var ballsCountLabel: SKLabelNode!
    var ballsArray = [String]()
   
    var ballCount = 5 {
        didSet {
            if ballCount == 0 {
                // comment создать лейбл с окончанием игры также создать условие else ещё лейбл с колво шаров
                ballsCountLabel.text = "End game!"

                goToGameScene()
            } else {
                ballsCountLabel.text = "\(ballCount) balls left"


            }
        }
    }
    

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!

    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
//        endGameLabel = SKLabelNode(fontNamed: "Chulkduster")
//        endGameLabel.text = "End game!"
//        endGameLabel.horizontalAlignmentMode = .right
//        endGameLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
//        addChild(endGameLabel)
        
        ballsCountLabel = SKLabelNode(fontNamed: "Chulkduster")
        ballsCountLabel.text = "5 balls left"
        ballsCountLabel.horizontalAlignmentMode = .right
        ballsCountLabel.position = CGPoint(x: 800, y: 700)
        addChild(ballsCountLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chulkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballsArray += ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        

    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location

                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false

                addChild(box)
            } else {
                let ball = SKSpriteNode(imageNamed: ballsArray.randomElement()!)
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
            ball.physicsBody?.restitution = 0.4
            ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                let screenHeight = UIScreen.main.bounds.height
                ball.position = CGPoint(x: location.x, y: screenHeight - 80.0)
            ball.name = "ball"
            addChild(ball)
        }
    }
}
    

    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode

        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }

        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode, box: SKNode) {
        if object.name == "good" {
            destroy(ball: ball, box: box)
            if ballCount < 5 {
                ballCount += 1
            }
            
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball, box: box)
            ballCount -= 1
            score -= 1
        }
    }

    func destroy(ball: SKNode, box: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
        
        if ballCount == 0 {
            goToGameScene()
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
            guard let nodeB = contact.bodyB.node else { return }

            if nodeA.name == "ball" {
                collisionBetween(ball: nodeA, object: nodeB, box: nodeA)
            } else if nodeB.name == "ball" {
                collisionBetween(ball: nodeB, object: nodeA, box: nodeA)
            }
        }
    func goToGameScene(){
        let gameScene:GameScene = GameScene(size: self.view!.bounds.size)
        let transition = SKTransition.fade(withDuration: 1.0)
        gameScene.scaleMode = .aspectFit
        self.view!.presentScene(gameScene, transition: transition)
    }

    
}
