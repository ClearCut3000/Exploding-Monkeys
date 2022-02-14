//
//  GameScene.swift
//  Exploding Monkeys
//
//  Created by Николай Никитин on 14.02.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

  //MARK: - Properties
  var buildings = [BuildingNode]()

  //MARK: - Scene
  override func didMove(to view: SKView) {
    backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
    createBuildings()
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
}
