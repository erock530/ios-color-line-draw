//
//  GalleryScene.swift
//  ColorLineDraw
//
//  Gallery view for saved drawings
//

import SpriteKit
import UIKit

class GalleryScene: SKScene {
    
    private var drawings: [SavedDrawing] = []
    private var scrollNode: SKNode?
    private var contentNode: SKNode?
    private var startTouchY: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var maxOffset: CGFloat = 0
    
    // Safe area insets
    var safeAreaInsets: UIEdgeInsets {
        return view?.window?.safeAreaInsets ?? UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupGallery()
    }
    
    private func setupGallery() {
        backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
        
        // Load drawings
        drawings = DrawingManager.shared.getAllDrawings()
        
        // Title bar
        setupTitleBar()
        
        // Gallery content
        setupGalleryContent()
        
        // Back button
        setupBackButton()
    }
    
    private func setupTitleBar() {
        // Background bar
        let topBarBG = SKShapeNode(rectOf: CGSize(width: frame.width, height: 70))
        topBarBG.position = CGPoint(x: frame.midX, y: frame.maxY - 35 - safeAreaInsets.top)
        topBarBG.fillColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.95)
        topBarBG.strokeColor = UIColor(white: 0.85, alpha: 1.0)
        topBarBG.lineWidth = 1
        topBarBG.zPosition = 100
        addChild(topBarBG)
        
        // Back button
        let backButton = SKShapeNode(circleOfRadius: 22)
        backButton.position = CGPoint(x: 40, y: frame.maxY - 35 - safeAreaInsets.top)
        backButton.fillColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        backButton.strokeColor = .clear
        backButton.name = "backButton"
        backButton.zPosition = 101
        
        let backLabel = SKLabelNode(text: "←")
        backLabel.fontSize = 28
        backLabel.verticalAlignmentMode = .center
        backLabel.fontColor = .white
        backLabel.name = "backButton"
        backButton.addChild(backLabel)
        addChild(backButton)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "My Gallery"
        titleLabel.fontSize = 24
        titleLabel.fontColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 43 - safeAreaInsets.top)
        titleLabel.zPosition = 101
        addChild(titleLabel)
        
        // New Drawing button
        let newButton = SKShapeNode(circleOfRadius: 22)
        newButton.position = CGPoint(x: frame.width - 40, y: frame.maxY - 35 - safeAreaInsets.top)
        newButton.fillColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        newButton.strokeColor = .clear
        newButton.name = "newDrawingButton"
        newButton.zPosition = 101
        
        let plusLabel = SKLabelNode(text: "+")
        plusLabel.fontSize = 32
        plusLabel.verticalAlignmentMode = .center
        plusLabel.fontColor = .white
        plusLabel.name = "newDrawingButton"
        newButton.addChild(plusLabel)
        addChild(newButton)
    }
    
    private func setupGalleryContent() {
        // Create scroll container
        scrollNode = SKNode()
        scrollNode?.zPosition = 10
        addChild(scrollNode!)
        
        contentNode = SKNode()
        scrollNode?.addChild(contentNode!)
        
        if drawings.isEmpty {
            showEmptyState()
        } else {
            layoutDrawings()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        emptyLabel.text = "No drawings yet"
        emptyLabel.fontSize = 22
        emptyLabel.fontColor = UIColor(white: 0.6, alpha: 1.0)
        emptyLabel.position = CGPoint(x: frame.midX, y: frame.midY + 30)
        contentNode?.addChild(emptyLabel)
        
        let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        hintLabel.text = "Tap + to create your first masterpiece!"
        hintLabel.fontSize = 16
        hintLabel.fontColor = UIColor(white: 0.5, alpha: 1.0)
        hintLabel.position = CGPoint(x: frame.midX, y: frame.midY - 10)
        contentNode?.addChild(hintLabel)
    }
    
    private func layoutDrawings() {
        let columns: CGFloat = 2
        let spacing: CGFloat = 20
        let cardWidth: CGFloat = (frame.width - spacing * (columns + 1)) / columns
        let cardHeight: CGFloat = cardWidth + 60
        
        let topY = frame.maxY - 100 - safeAreaInsets.top
        let bottomY = frame.minY + 80 + safeAreaInsets.bottom
        
        for (index, drawing) in drawings.enumerated() {
            let column = CGFloat(index % Int(columns))
            let row = CGFloat(index / Int(columns))
            
            let x = spacing + column * (cardWidth + spacing) + cardWidth / 2
            let y = topY - row * (cardHeight + spacing) - cardHeight / 2
            
            createDrawingCard(drawing: drawing, position: CGPoint(x: x, y: y), size: CGSize(width: cardWidth, height: cardHeight))
        }
        
        // Calculate max scroll offset
        let rows = ceil(CGFloat(drawings.count) / columns)
        let contentHeight = rows * (cardHeight + spacing) + spacing
        let visibleHeight = topY - bottomY
        maxOffset = max(0, contentHeight - visibleHeight)
    }
    
    private func createDrawingCard(drawing: SavedDrawing, position: CGPoint, size: CGSize) {
        let card = SKNode()
        card.position = position
        card.name = "drawingCard_\(drawing.id.uuidString)"
        
        // Card background
        let cardBG = SKShapeNode(rectOf: size, cornerRadius: 15)
        cardBG.fillColor = .white
        cardBG.strokeColor = UIColor(red: 0.8, green: 0.85, blue: 0.95, alpha: 1.0)
        cardBG.lineWidth = 2
        cardBG.name = "drawingCard_\(drawing.id.uuidString)"
        card.addChild(cardBG)
        
        // Thumbnail
        let thumbnailSize = CGSize(width: size.width - 20, height: size.width - 20)
        if let thumbnail = DrawingManager.shared.loadThumbnail(drawing) {
            let texture = SKTexture(image: thumbnail)
            let imageNode = SKSpriteNode(texture: texture, size: thumbnailSize)
            imageNode.position = CGPoint(x: 0, y: 15)
            imageNode.name = "drawingCard_\(drawing.id.uuidString)"
            card.addChild(imageNode)
        } else {
            // Placeholder if thumbnail fails to load
            let placeholder = SKShapeNode(rectOf: thumbnailSize, cornerRadius: 10)
            placeholder.fillColor = UIColor(white: 0.95, alpha: 1.0)
            placeholder.strokeColor = .clear
            placeholder.position = CGPoint(x: 0, y: 15)
            card.addChild(placeholder)
        }
        
        // Date label
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let dateLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        dateLabel.text = dateFormatter.string(from: drawing.dateModified)
        dateLabel.fontSize = 12
        dateLabel.fontColor = UIColor(white: 0.5, alpha: 1.0)
        dateLabel.position = CGPoint(x: 0, y: -size.height / 2 + 20)
        dateLabel.name = "drawingCard_\(drawing.id.uuidString)"
        card.addChild(dateLabel)
        
        // Delete button
        let deleteButton = SKShapeNode(circleOfRadius: 15)
        deleteButton.position = CGPoint(x: size.width / 2 - 20, y: size.height / 2 - 20)
        deleteButton.fillColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.9)
        deleteButton.strokeColor = .white
        deleteButton.lineWidth = 2
        deleteButton.name = "deleteButton_\(drawing.id.uuidString)"
        deleteButton.zPosition = 5
        
        let deleteLabel = SKLabelNode(text: "✕")
        deleteLabel.fontSize = 16
        deleteLabel.fontColor = .white
        deleteLabel.verticalAlignmentMode = .center
        deleteLabel.name = "deleteButton_\(drawing.id.uuidString)"
        deleteButton.addChild(deleteLabel)
        card.addChild(deleteButton)
        
        contentNode?.addChild(card)
    }
    
    private func setupBackButton() {
        // This is already in setupTitleBar, but keeping this method for consistency
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        startTouchY = location.y
        
        for node in touchedNodes {
            guard let name = node.name else { continue }
            
            if name == "backButton" {
                goBack()
                return
            } else if name == "newDrawingButton" {
                createNewDrawing()
                return
            } else if name.hasPrefix("deleteButton_") {
                let idString = name.replacingOccurrences(of: "deleteButton_", with: "")
                if let uuid = UUID(uuidString: idString) {
                    confirmDelete(drawingId: uuid)
                }
                return
            } else if name.hasPrefix("drawingCard_") {
                let idString = name.replacingOccurrences(of: "drawingCard_", with: "")
                if let uuid = UUID(uuidString: idString) {
                    openDrawing(drawingId: uuid)
                }
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let deltaY = location.y - startTouchY
        let newOffset = currentOffset + deltaY
        
        // Clamp offset
        let clampedOffset = max(min(newOffset, 0), -maxOffset)
        contentNode?.position.y = clampedOffset
        
        startTouchY = location.y
        currentOffset = clampedOffset
    }
    
    // MARK: - Actions
    
    private func goBack() {
        let transition = SKTransition.fade(withDuration: 0.3)
        let menuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .aspectFill
        self.view?.presentScene(menuScene, transition: transition)
    }
    
    private func createNewDrawing() {
        let transition = SKTransition.fade(withDuration: 0.3)
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    private func openDrawing(drawingId: UUID) {
        guard let drawing = DrawingManager.shared.getDrawing(by: drawingId),
              let image = DrawingManager.shared.loadDrawing(drawing) else {
            return
        }
        
        let transition = SKTransition.fade(withDuration: 0.3)
        let gameScene = GameScene(size: self.size)
        gameScene.loadDrawing(image: image, drawingId: drawingId)
        gameScene.scaleMode = .aspectFill
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    private func confirmDelete(drawingId: UUID) {
        guard let drawing = DrawingManager.shared.getDrawing(by: drawingId) else { return }
        
        let alert = UIAlertController(
            title: "Delete Drawing?",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            DrawingManager.shared.deleteDrawing(drawing)
            self?.refreshGallery()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
    
    private func refreshGallery() {
        // Remove all content
        contentNode?.removeAllChildren()
        
        // Reload drawings
        drawings = DrawingManager.shared.getAllDrawings()
        
        // Recreate layout
        if drawings.isEmpty {
            showEmptyState()
        } else {
            layoutDrawings()
        }
        
        // Reset scroll
        currentOffset = 0
        contentNode?.position.y = 0
    }
}
