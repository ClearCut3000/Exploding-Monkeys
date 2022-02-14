//
//  BuildingNode.swift
//  Exploding Monkeys
//
//  Created by Николай Никитин on 14.02.2022.
//

import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {

  //MARK: - Properties
  private var currentImage: UIImage!

  //MARK: - Methods
  func setup() {
    name = "bilding"
    currentImage = drawBuilding(size: size)
    texture = SKTexture(image: currentImage)
    configurePhysics()
  }

  private func configurePhysics() {
    physicsBody = SKPhysicsBody(texture: texture!, size: size)
    physicsBody?.isDynamic = false
    physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
    physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
  }

  private func drawBuilding(size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
      let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      let color: UIColor
      switch Int.random(in: 0...2) {
      case 0:
        color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
      case 1:
        color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
      default:
        color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
      }
      color.setFill()
      context.cgContext.addRect(rectangle)
      context.cgContext.drawPath(using: .fill)
      let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
      let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
      for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
        for column in stride(from: 10, to: Int(size.width - 10), by: 40) {
          if Bool.random() {
            lightOnColor.setFill()
          } else {
            lightOffColor.setFill()
          }
          context.cgContext.fill(CGRect(x: column, y: row, width: 15, height: 20))
        }
      }
    }
    return image
  }
}
