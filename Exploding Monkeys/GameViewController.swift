//
//  GameViewController.swift
//  Exploding Monkeys
//
//  Created by Николай Никитин on 14.02.2022.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  //MARK: - Properties
  var currentGame: GameScene!
  var isGameOver = false
  var playerOneScore = 0 {
    didSet {
      playerOneScoreLabel.text = "\(playerOneScore)"
      checkForWinner()
    }
  }
  var playerTwoScore = 0 {
    didSet {
      playerTwoScoreLabel.text = "\(playerTwoScore)"
      checkForWinner()
    }
  }

  //MARK: - Outlets
  @IBOutlet var angleSlider: UISlider!
  @IBOutlet var angleLabel: UILabel!
  @IBOutlet var velocitySlider: UISlider!
  @IBOutlet var velocityLabel: UILabel!
  @IBOutlet var launchButton: UIButton!
  @IBOutlet var playerNumber: UILabel!
  @IBOutlet var playerOneScoreLabel: UILabel!
  @IBOutlet var playerTwoScoreLabel: UILabel!

  //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
              currentGame = scene as? GameScene
              currentGame?.viewController = self

            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
      angleChanged(self)
      velocityChanged(self)
    }


  //MARK: - ViewController Interface Methods
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

  //MARK: - Methods
  private func checkForWinner() {
    if playerOneScore == 3 {
      hideControls(true)
      isGameOver = true
      playerNumber.textAlignment = .center
      playerNumber.text = "Player One Win's!"
    } else if playerTwoScore == 3 {
      hideControls(true)
      isGameOver = true
      playerNumber.textAlignment = .center
      playerNumber.text = "Player Two Win's!"
    }
  }

  func activatePlayer(number: Int) {
    if number == 1 {
      playerNumber.textAlignment = .left
      playerNumber.text = "<<< PLAYER ONE"
    } else {
      playerNumber.textAlignment = .right
      playerNumber.text = "PLAYER TWO >>>"
    }
    hideControls(false)
  }

  private func hideControls(_ bool: Bool) {
    angleSlider.isHidden = bool
    angleLabel.isHidden = bool
    velocitySlider.isHidden = bool
    velocityLabel.isHidden = bool
    launchButton.isHidden = bool
  }

  //MARK: - Actions
  @IBAction func angleChanged(_ sender: Any) {
    angleLabel.text = "Angle: \(Int(angleSlider.value))°"
  }

  @IBAction func velocityChanged(_ sender: Any) {
    velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
  }

  @IBAction func launch(_ sender: Any) {
    hideControls(true)
    currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
  }
}
