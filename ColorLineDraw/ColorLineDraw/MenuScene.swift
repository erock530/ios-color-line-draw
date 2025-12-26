//
//  MenuScene.swift
//  ColorLineDraw
//
//  Enhanced menu system
//

import SpriteKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupMenu()
    }
    
    private func setupMenu() {
        // Background gradient effect
        backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Color Line Draw"
        titleLabel.fontSize = 48
        titleLabel.fontColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitleLabel.text = "Express Your Creativity"
        subtitleLabel.fontSize = 20
        subtitleLabel.fontColor = UIColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 1.0)
        subtitleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
        
        // Decorative lines animation
        createDecorativeLines()
        
        // Start Button
        createMenuButton(
            name: "startButton",
            text: "Start Drawing",
            position: CGPoint(x: frame.midX, y: frame.midY + 20),
            color: UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        )
        
        // Gallery Button (placeholder for future feature)
        createMenuButton(
            name: "galleryButton",
            text: "Gallery",
            position: CGPoint(x: frame.midX, y: frame.midY - 60),
            color: UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        )
        
        // Settings Button
        createMenuButton(
            name: "settingsButton",
            text: "Settings",
            position: CGPoint(x: frame.midX, y: frame.midY - 140),
            color: UIColor(red: 0.6, green: 0.7, blue: 0.85, alpha: 1.0)
        )
        
        // About Button
        createMenuButton(
            name: "aboutButton",
            text: "About",
            position: CGPoint(x: frame.midX, y: frame.midY - 220),
            color: UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0)
        )
    }
    
    private func createMenuButton(name: String, text: String, position: CGPoint, color: UIColor) {
        let buttonWidth: CGFloat = 250
        let buttonHeight: CGFloat = 60
        
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 15)
        button.position = position
        button.fillColor = color
        button.strokeColor = UIColor(white: 1.0, alpha: 0.3)
        button.lineWidth = 2
        button.name = name
        button.zPosition = 10
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        label.zPosition = 11
        
        button.addChild(label)
        addChild(button)
        
        // Subtle animation
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        button.alpha = 0
        button.setScale(0.8)
        button.run(SKAction.group([fadeIn, scaleUp]))
    }
    
    private func createDecorativeLines() {
        for i in 0..<5 {
            let line = SKShapeNode()
            let path = CGMutablePath()
            let startX = CGFloat.random(in: 0...frame.width)
            let startY = CGFloat.random(in: 0...frame.height)
            let endX = CGFloat.random(in: 0...frame.width)
            let endY = CGFloat.random(in: 0...frame.height)
            
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: endX, y: endY))
            
            line.path = path
            line.strokeColor = UIColor(hue: CGFloat(i) / 5.0, saturation: 0.6, brightness: 0.9, alpha: 0.3)
            line.lineWidth = 3
            line.lineCap = .round
            line.zPosition = 1
            
            addChild(line)
            
            // Gentle floating animation
            let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 2.0)
            let moveDown = SKAction.moveBy(x: 0, y: -20, duration: 2.0)
            let sequence = SKAction.sequence([moveUp, moveDown])
            let forever = SKAction.repeatForever(sequence)
            line.run(forever)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            guard let name = node.name else { continue }
            
            if name == "startButton" {
                animateButtonPress(node) {
                    self.startGame()
                }
            } else if name == "galleryButton" {
                animateButtonPress(node) {
                    self.showGallery()
                }
            } else if name == "settingsButton" {
                animateButtonPress(node) {
                    self.showSettings()
                }
            } else if name == "aboutButton" {
                animateButtonPress(node) {
                    self.showAbout()
                }
            }
        }
    }
    
    private func animateButtonPress(_ node: SKNode, completion: @escaping () -> Void) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        node.run(sequence) {
            completion()
        }
    }
    
    private func startGame() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    private func showGallery() {
        // Placeholder - could show saved drawings
        let alert = UIAlertController(title: "Gallery", message: "Coming soon! Save and view your artwork.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
    
    private func showSettings() {
        let settingsScene = SettingsScene(size: self.size)
        settingsScene.scaleMode = .aspectFill
        let transition = SKTransition.push(with: .left, duration: 0.3)
        self.view?.presentScene(settingsScene, transition: transition)
    }
    
    private func showAbout() {
        let alert = UIAlertController(
            title: "About Color Line Draw",
            message: "Version 2.0\n\nCreate beautiful artwork with rainbow colors, custom brushes, and creative tools.\n\nTap and drag to draw, use the toolbar to customize your experience!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
}
