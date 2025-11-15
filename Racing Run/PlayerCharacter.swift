//
//  PlayerCharacter.swift
//  Racing Run
//
//  Created by Nathan Fennel on 10/8/25.
//

import SpriteKit

class PlayerCharacter: SKNode {

    private var bodyNode: SKSpriteNode!
    private var faceNode: SKSpriteNode!

    override init() {
        super.init()
        setupCharacter()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCharacter()
    }

    private func setupCharacter() {
        // Create the body - a simple colored rectangle for now
        // Your son can help design what the body should look like!
        bodyNode = SKSpriteNode(color: .systemBlue, size: CGSize(width: 60, height: 100))
        bodyNode.name = "body"

        // Add the face on top of the body
        if let faceImage = CharacterImageManager.shared.loadCharacterFace() {
            let texture = SKTexture(image: faceImage)
            faceNode = SKSpriteNode(texture: texture)
            faceNode.size = CGSize(width: 50, height: 50)
            faceNode.position = CGPoint(x: 0, y: 35) // Position at the top of the body
            faceNode.name = "face"

            // Make the face circular
            let circlePath = CGPath(ellipseIn: CGRect(x: -25, y: -25, width: 50, height: 50), transform: nil)
            let maskNode = SKShapeNode(path: circlePath)
            maskNode.fillColor = .white
            faceNode.mask = maskNode

            bodyNode.addChild(faceNode)
        }

        addChild(bodyNode)

        // Add physics if needed for the game
        setupPhysics()
    }

    private func setupPhysics() {
        // Physics body for collisions
        let bodySize = CGSize(width: 60, height: 100)
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = 1
        physicsBody?.contactTestBitMask = 2
        physicsBody?.collisionBitMask = 2
    }

    // MARK: - Animation Methods

    /// Make the character run (animate)
    func startRunning() {
        // Simple bobbing animation to simulate running
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.2)
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.2)
        let sequence = SKAction.sequence([moveUp, moveDown])
        let repeatAction = SKAction.repeatForever(sequence)
        bodyNode.run(repeatAction, withKey: "running")
    }

    /// Stop the running animation
    func stopRunning() {
        bodyNode.removeAction(forKey: "running")
    }

    /// Make the character jump
    func jump() {
        guard let physicsBody = physicsBody else { return }

        // Only jump if on the ground (not already jumping)
        if physicsBody.velocity.dy == 0 {
            physicsBody.applyImpulse(CGVector(dx: 0, dy: 50))
        }
    }

    /// Move the character forward
    func moveForward(speed: CGFloat = 200) {
        guard let physicsBody = physicsBody else { return }
        physicsBody.velocity.dx = speed
    }

    /// Update the character's face image
    func updateFace() {
        if let faceImage = CharacterImageManager.shared.loadCharacterFace() {
            let texture = SKTexture(image: faceImage)
            faceNode?.texture = texture
        }
    }
}
