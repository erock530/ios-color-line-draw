//
//  SettingsScene.swift
//  ColorLineDraw
//
//  Settings and preferences
//

import SpriteKit

class SettingsScene: SKScene {
    
    // Safe area insets
    var safeAreaInsets: UIEdgeInsets {
        return view?.window?.safeAreaInsets ?? UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupSettings()
    }
    
    private func setupSettings() {
        backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
        
        // Title (accounting for safe area at top)
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Settings"
        titleLabel.fontSize = 40
        titleLabel.fontColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100 - safeAreaInsets.top)
        addChild(titleLabel)
        
        // Settings info
        let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        infoLabel.text = "Customize Your Experience"
        infoLabel.fontSize = 18
        infoLabel.fontColor = UIColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 1.0)
        infoLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 150 - safeAreaInsets.top)
        addChild(infoLabel)
        
        // Settings options (placeholders for future features)
        let settingsOptions = [
            "🎨 Default Drawing Mode: Rainbow",
            "✏️ Default Brush Size: Medium",
            "💾 Auto-Save: On",
            "🔊 Sound Effects: On",
            "✨ Animations: On"
        ]
        
        var yPosition = frame.midY + 100
        for option in settingsOptions {
            let optionLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            optionLabel.text = option
            optionLabel.fontSize = 20
            optionLabel.fontColor = UIColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1.0)
            optionLabel.position = CGPoint(x: frame.midX, y: yPosition)
            optionLabel.horizontalAlignmentMode = .center
            addChild(optionLabel)
            
            yPosition -= 60
        }
        
        // Back Button
        createBackButton()
    }
    
    private func createBackButton() {
        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        button.position = CGPoint(x: frame.midX, y: frame.minY + 100 + safeAreaInsets.bottom)
        button.fillColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        button.strokeColor = .white
        button.lineWidth = 2
        button.name = "backButton"
        button.zPosition = 10
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Back to Menu"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "backButton"
        
        button.addChild(label)
        addChild(button)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "backButton" {
                let transition = SKTransition.push(with: .right, duration: 0.3)
                let menuScene = MenuScene(size: self.size)
                menuScene.scaleMode = .aspectFill
                self.view?.presentScene(menuScene, transition: transition)
            }
        }
    }
}
