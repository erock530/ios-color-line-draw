//
//  GameViewController.swift
//  ColorLineDraw
//
//  Created by Eric Colangelo on 4/22/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {
            // Create and present the menu scene
            let menuScene = MenuScene(size: skView.bounds.size)
            menuScene.scaleMode = SKSceneScaleMode.aspectFill
            
            // Present the scene
            skView.presentScene(menuScene)
            
            skView.ignoresSiblingOrder = true
            
            // Comment these out for production
            // skView.showsFPS = true
            // skView.showsNodeCount = true
        }
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
}
