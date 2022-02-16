//
//  GameScene.swift
//  Exploding Monkeys
//
//  Created by Николай Никитин on 14.02.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

  //MARK: - Properties
  private var buildings = [BuildingNode]()
  weak var viewController: GameViewController?
  private var playerOne: SKSpriteNode!
  private var playerTwo: SKSpriteNode!
  private var banana: SKSpriteNode!
  private var currentPlayer = 1

  //MARK: - Scene
  override func didMove(to view: SKView) {
    backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
    createBuildings()
    createPlayers()
    physicsWorld.contactDelegate = self
  }

  override func update(_ currentTime: TimeInterval) {
    guard banana != nil else { return }
    if abs(banana.position.y) > 1_000 {
      banana.removeFromParent()
      banana = nil
      changePlayer()
    }
  }

  //MARK: - Methods
  private func createBuildings() {
    var currentX: CGFloat = -15
    while currentX < 1024 {
      let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
      currentX += size.width + 2
      let building = BuildingNode(color: .red, size: size)
      building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
      building.setup()
      addChild(building)
      buildings.append(building)
    }
  }

  private func launch(angle: Int, velocity: Int) {
    let speed = Double(velocity) / 10
    let radians = deg2rad(degrees: angle)
    if banana != nil {
      banana.removeFromParent()
      banana = nil
    }
    banana = SKSpriteNode(imageNamed: "banana")
    banana.name = "banana"
    banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
    banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
    banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
    banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
    banana.physicsBody?.usesPreciseCollisionDetection = true
    addChild(banana)
    if currentPlayer == 1 {
      banana.position = CGPoint(x: playerOne.position.x - 30, y: playerOne.position.y + 40)
      banana.physicsBody?.angularVelocity = -20
      let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
      let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
      let pause = SKAction.wait(forDuration: 0.15)
      let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
      playerOne.run(sequence)
      let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
      banana.physicsBody?.applyImpulse(impulse)
    } else {
      banana.position = CGPoint(x: playerTwo.position.x + 30, y: playerTwo.position.y + 40)
      banana.physicsBody?.angularVelocity = -20
      let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
      let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
      let pause = SKAction.wait(forDuration: 0.15)
      let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
      playerTwo.run(sequence)
      let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
      banana.physicsBody?.applyImpulse(impulse)
    }
  }

  private func createPlayers() {
    ///First Player Node
    playerOne = SKSpriteNode(imageNamed: "player")
    playerOne.name = "player1"
    playerOne.physicsBody = SKPhysicsBody(circleOfRadius: playerOne.size.width / 2)
    playerOne.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
    playerOne.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
    playerOne.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    playerOne.physicsBody?.isDynamic = false
    let playerOneBuilding = buildings[1]
    playerOne.position = CGPoint(x: playerOneBuilding.position.x, y: playerOneBuilding.position.y + ((playerOneBuilding.size.height + playerOne.size.height) / 2))
    addChild(playerOne)
    ///Second Player Node
    playerTwo = SKSpriteNode(imageNamed: "player")
    playerTwo.name = "player2"
    playerTwo.physicsBody = SKPhysicsBody(circleOfRadius: playerTwo.size.width / 2)
    playerTwo.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
    playerTwo.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
    playerTwo.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    playerTwo.physicsBody?.isDynamic = false
    let playerTwoBuilding = buildings[buildings.count - 2]
    playerTwo.position = CGPoint(x: playerTwoBuilding.position.x, y: playerTwoBuilding.position.y + ((playerTwoBuilding.size.height + playerTwo.size.height) / 2))
    addChild(playerTwo)
  }

  private func deg2rad(degrees: Int) -> Double {
    return Double(degrees) * .pi / 180
  }

  private func destroy(player: SKSpriteNode) {
    if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
      explosion.position = player.position
      addChild(explosion)
    }
    player.removeFromParent()
    banana.removeFromParent()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      let newGame = GameScene(size: self.size)
      newGame.viewController = self.viewController
      self.viewController?.currentGame = newGame
      self.changePlayer()
      newGame.currentPlayer = self.currentPlayer
      let transition = SKTransition.doorway(withDuration: 1.5)
      self.view?.presentScene(newGame, transition: transition)
    }
  }

  private func changePlayer() {
    currentPlayer = (currentPlayer == 1) ? 2 : 1
    viewController?.activatePlayer(number: currentPlayer)
  }

  private func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
    guard let building = building as? BuildingNode else { return }
    let buildingLocation = convert(contactPoint, to: building)
    building.hit(at: buildingLocation)
    if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
      explosion.position = contactPoint
      addChild(explosion)
    }
    banana.name = ""
    banana.removeFromParent()
    banana = nil
    changePlayer()
  }

  //MARK: - Collision and contact methods
  func didBegin(_ contact: SKPhysicsContact) {
    let firstBody: SKPhysicsBody
    let secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    guard let firstNode = firstBody.node else { return }
    guard let secondNode = secondBody.node else { return }
    if firstNode.name == "banana" && secondNode.name == "building" {
      bananaHit(building: secondNode, atPoint: contact.contactPoint)
    }
    if firstNode.name == "banana" && secondNode.name == "player1" {
      destroy(player: playerOne)
    }
    if firstNode.name == "banana" && secondNode.name == "player2" {
      destroy(player: playerTwo)
    }
  }
}
