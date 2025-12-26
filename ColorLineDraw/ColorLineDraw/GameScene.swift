import SpriteKit

enum DrawingMode {
    case rainbow
    case singleColor
    case eraser
}

class GameScene: SKScene {
    // Drawing properties
    var currentLine: SKShapeNode?
    var lineColor: UIColor = UIColor(hue: 0.5, saturation: 1, brightness: 1, alpha: 1)
    var lineWidth: CGFloat = 5
    var drawingMode: DrawingMode = .rainbow
    
    // History for undo/redo
    var drawingHistory: [SKShapeNode] = []
    var redoStack: [SKShapeNode] = []
    
    // UI Container
    var toolbarNode: SKNode?
    var isToolbarArea: Bool = false
    
    // Rainbow mode
    var rainbowHue: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .white
        setupToolbar()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        
        // Check if touch is on toolbar
        if position.y < 120 {
            handleToolbarTouch(at: position)
            return
        }
        
        // Start drawing
        startLine(at: position)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        
        // Don't draw in toolbar area
        if position.y < 120 { return }
        
        continueLine(to: position)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentLine != nil {
            currentLine = nil
        }
    }
    
    // MARK: - Drawing Functions
    
    func startLine(at position: CGPoint) {
        redoStack.removeAll() // Clear redo stack on new action
        
        currentLine = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: position)
        currentLine?.path = path
        
        if drawingMode == .eraser {
            currentLine?.strokeColor = .white
            currentLine?.lineWidth = lineWidth * 2
        } else {
            currentLine?.strokeColor = lineColor
            currentLine?.lineWidth = lineWidth
        }
        
        currentLine?.lineCap = .round
        currentLine?.lineJoin = .round
        self.addChild(currentLine!)
        drawingHistory.append(currentLine!)
    }
    
    func continueLine(to position: CGPoint) {
        guard let currentLine = currentLine,
              let path = currentLine.path else { return }
        
        let mutablePath = path.mutableCopy()
        mutablePath?.addLine(to: position)
        currentLine.path = mutablePath
        
        if drawingMode == .rainbow {
            updateRainbowColor()
        }
    }
    
    func updateRainbowColor() {
        rainbowHue += 0.01
        if rainbowHue > 1.0 { rainbowHue = 0.0 }
        lineColor = UIColor(hue: rainbowHue, saturation: 1, brightness: 1, alpha: 1)
        currentLine?.strokeColor = lineColor
    }
    
    // MARK: - Tool Actions
    
    func clearScreen() {
        drawingHistory.forEach { $0.removeFromParent() }
        drawingHistory.removeAll()
        redoStack.removeAll()
    }
    
    func undoLastLine() {
        guard let lastLine = drawingHistory.popLast() else { return }
        lastLine.removeFromParent()
        redoStack.append(lastLine)
    }
    
    func redoLastLine() {
        guard let lastLine = redoStack.popLast() else { return }
        self.addChild(lastLine)
        drawingHistory.append(lastLine)
    }
    
    func setLineWidth(_ width: CGFloat) {
        lineWidth = width
        updateToolbarSelection()
    }
    
    func setDrawingMode(_ mode: DrawingMode) {
        drawingMode = mode
        updateToolbarSelection()
    }
    
    func pickColor(_ color: UIColor) {
        lineColor = color
        drawingMode = .singleColor
        updateToolbarSelection()
    }
    
    func saveDrawing() {
        // Hide toolbar for clean screenshot
        toolbarNode?.isHidden = true
        
        // Render the scene to an image
        let texture = view?.texture(from: self)
        
        // Show toolbar again
        toolbarNode?.isHidden = false
        
        guard let texture = texture else {
            showAlert(title: "Error", message: "Could not save drawing")
            return
        }
        
        let cgImage = texture.cgImage()
        let image = UIImage(cgImage: cgImage)
        
        // Save to photo library
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Save Failed", message: error.localizedDescription)
        } else {
            showAlert(title: "Success! 🎉", message: "Your artwork has been saved to Photos")
        }
    }
    
    func shareDrawing() {
        // Hide toolbar for clean screenshot
        toolbarNode?.isHidden = true
        
        // Render the scene to an image
        let texture = view?.texture(from: self)
        
        // Show toolbar again
        toolbarNode?.isHidden = false
        
        guard let texture = texture else {
            showAlert(title: "Error", message: "Could not share drawing")
            return
        }
        
        let cgImage = texture.cgImage()
        let image = UIImage(cgImage: cgImage)
        
        // Share via activity view controller
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let viewController = self.view?.window?.rootViewController {
            // For iPad: configure popover
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                          y: viewController.view.bounds.midY,
                                          width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            viewController.present(activityVC, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
    
    // MARK: - Toolbar Setup
    
    private func setupToolbar() {
        toolbarNode?.removeFromParent()
        toolbarNode = SKNode()
        
        // Background for toolbar
        let toolbarBG = SKShapeNode(rectOf: CGSize(width: frame.width, height: 100))
        toolbarBG.position = CGPoint(x: frame.midX, y: 50)
        toolbarBG.fillColor = UIColor(white: 0.95, alpha: 1.0)
        toolbarBG.strokeColor = UIColor(white: 0.8, alpha: 1.0)
        toolbarBG.lineWidth = 1
        toolbarBG.zPosition = 100
        toolbarNode?.addChild(toolbarBG)
        
        let buttonSpacing: CGFloat = 70
        let startX: CGFloat = 40
        
        // Menu Button (back to menu)
        createToolButton(name: "menu", text: "☰", position: CGPoint(x: 25, y: 75))
        
        // Share Button (top row, right side)
        createToolButton(name: "share", text: "📤", position: CGPoint(x: frame.maxX - 90, y: 75))
        
        // Save Button (top row, right side)
        createToolButton(name: "save", text: "💾", position: CGPoint(x: frame.maxX - 30, y: 75))
        
        // Undo Button
        createToolButton(name: "undo", text: "↶", position: CGPoint(x: startX, y: 50))
        
        // Redo Button
        createToolButton(name: "redo", text: "↷", position: CGPoint(x: startX + buttonSpacing, y: 50))
        
        // Clear Button
        createToolButton(name: "clear", text: "✕", position: CGPoint(x: startX + buttonSpacing * 2, y: 50))
        
        // Rainbow Mode Button
        createToolButton(name: "rainbow", text: "🌈", position: CGPoint(x: startX + buttonSpacing * 3, y: 50), selected: drawingMode == .rainbow)
        
        // Eraser Button
        createToolButton(name: "eraser", text: "⌫", position: CGPoint(x: startX + buttonSpacing * 4, y: 50), selected: drawingMode == .eraser)
        
        // Line Width Buttons
        createLineWidthButton(name: "thin", width: 2, position: CGPoint(x: frame.maxX - 180, y: 50))
        createLineWidthButton(name: "medium", width: 5, position: CGPoint(x: frame.maxX - 120, y: 50))
        createLineWidthButton(name: "thick", width: 10, position: CGPoint(x: frame.maxX - 60, y: 50))
        
        // Color Palette (bottom row)
        let colorY: CGFloat = 20
        let colors: [(String, UIColor)] = [
            ("red", .red),
            ("orange", .orange),
            ("yellow", .yellow),
            ("green", .green),
            ("cyan", .cyan),
            ("blue", .blue),
            ("purple", .purple),
            ("magenta", .magenta)
        ]
        
        for (index, colorData) in colors.enumerated() {
            let x = startX + CGFloat(index) * 40
            createColorButton(name: "color_\(colorData.0)", color: colorData.1, position: CGPoint(x: x, y: colorY))
        }
        
        self.addChild(toolbarNode!)
    }
    
    private func createToolButton(name: String, text: String, position: CGPoint, selected: Bool = false) {
        let button = SKShapeNode(circleOfRadius: 25)
        button.position = position
        button.fillColor = selected ? UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0) : .white
        button.strokeColor = UIColor(white: 0.7, alpha: 1.0)
        button.lineWidth = 2
        button.name = name
        button.zPosition = 101
        
        let label = SKLabelNode(text: text)
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        label.fontName = "Arial"
        label.name = name
        label.zPosition = 102
        button.addChild(label)
        
        toolbarNode?.addChild(button)
    }
    
    private func createLineWidthButton(name: String, width: CGFloat, position: CGPoint) {
        let button = SKShapeNode(circleOfRadius: 20)
        button.position = position
        button.fillColor = lineWidth == width ? UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0) : .white
        button.strokeColor = UIColor(white: 0.7, alpha: 1.0)
        button.lineWidth = 2
        button.name = name
        button.zPosition = 101
        
        let dot = SKShapeNode(circleOfRadius: width)
        dot.fillColor = .black
        dot.strokeColor = .clear
        dot.name = name
        dot.zPosition = 102
        button.addChild(dot)
        
        toolbarNode?.addChild(button)
    }
    
    private func createColorButton(name: String, color: UIColor, position: CGPoint) {
        let button = SKShapeNode(circleOfRadius: 15)
        button.position = position
        button.fillColor = color
        button.strokeColor = UIColor(white: 0.3, alpha: 1.0)
        button.lineWidth = 2
        button.name = name
        button.zPosition = 101
        
        toolbarNode?.addChild(button)
    }
    
    // MARK: - Toolbar Interaction
    
    private func handleToolbarTouch(at position: CGPoint) {
        let touchedNodes = nodes(at: position)
        
        for node in touchedNodes {
            guard let name = node.name else { continue }
            
            // Menu button
            if name == "menu" {
                returnToMenu()
                return
            }
            
            // Save button
            if name == "save" {
                saveDrawing()
                animateButtonPress(node)
                return
            }
            
            // Share button
            if name == "share" {
                shareDrawing()
                animateButtonPress(node)
                return
            }
            
            // Action buttons
            if name == "undo" {
                undoLastLine()
                animateButtonPress(node)
                return
            } else if name == "redo" {
                redoLastLine()
                animateButtonPress(node)
                return
            } else if name == "clear" {
                clearScreen()
                animateButtonPress(node)
                return
            } else if name == "rainbow" {
                setDrawingMode(.rainbow)
                animateButtonPress(node)
                return
            } else if name == "eraser" {
                setDrawingMode(.eraser)
                animateButtonPress(node)
                return
            }
            
            // Line width buttons
            if name == "thin" {
                setLineWidth(2)
                animateButtonPress(node)
                return
            } else if name == "medium" {
                setLineWidth(5)
                animateButtonPress(node)
                return
            } else if name == "thick" {
                setLineWidth(10)
                animateButtonPress(node)
                return
            }
            
            // Color buttons
            if name.hasPrefix("color_") {
                if let shapeNode = node as? SKShapeNode {
                    pickColor(shapeNode.fillColor)
                    animateButtonPress(node)
                    return
                }
            }
        }
    }
    
    private func returnToMenu() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let menuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .aspectFill
        self.view?.presentScene(menuScene, transition: transition)
    }
    
    private func animateButtonPress(_ node: SKNode) {
        let scaleDown = SKAction.scale(to: 0.85, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        node.run(sequence)
    }
    
    private func updateToolbarSelection() {
        setupToolbar() // Rebuild toolbar with current selection
    }
}

