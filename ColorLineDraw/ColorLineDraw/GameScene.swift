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
    
    // UI Containers
    var topBarNode: SKNode?
    var bottomBarNode: SKNode?
    var brushSizePanel: SKNode?
    var colorPalettePanel: SKNode?
    var menuPanel: SKNode?
    
    // UI State
    var isPanelOpen: Bool = false
    var isBrushPanelOpen: Bool = false
    var isColorPanelOpen: Bool = false
    
    // Rainbow mode
    var rainbowHue: CGFloat = 0.0
    
    // Safe drawing area (excludes UI)
    var drawingArea: CGRect {
        return CGRect(x: 0, y: 80, width: frame.width, height: frame.height - 160)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        
        // Check if touch is on UI elements
        if isTouchOnUI(position) {
            handleUITouch(at: position)
            return
        }
        
        // Close any open panels when drawing
        if isPanelOpen {
            closeAllPanels()
        }
        
        // Start drawing if in drawing area
        if drawingArea.contains(position) {
            startLine(at: position)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        
        // Only continue drawing if in drawing area
        if drawingArea.contains(position) && currentLine != nil {
            continueLine(to: position)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentLine != nil {
            currentLine = nil
        }
    }
    
    private func isTouchOnUI(_ position: CGPoint) -> Bool {
        // Top bar area
        if position.y > frame.height - 80 {
            return true
        }
        
        // Bottom bar area
        if position.y < 80 {
            return true
        }
        
        // Check if any panel is open and touched
        if isPanelOpen {
            return true
        }
        
        return false
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
        if isBrushPanelOpen {
            showBrushSizePanel() // Refresh to show new selection
        }
    }
    
    func setDrawingMode(_ mode: DrawingMode) {
        drawingMode = mode
        setupBottomBar() // Refresh to show new selection
    }
    
    func pickColor(_ color: UIColor) {
        lineColor = color
        drawingMode = .singleColor
        setupBottomBar() // Refresh UI
    }
    
    func saveDrawing() {
        // Hide UI for clean screenshot
        topBarNode?.isHidden = true
        bottomBarNode?.isHidden = true
        
        // Render the scene to an image
        let texture = view?.texture(from: self)
        
        // Show UI again
        topBarNode?.isHidden = false
        bottomBarNode?.isHidden = false
        
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
        // Hide UI for clean screenshot
        topBarNode?.isHidden = true
        bottomBarNode?.isHidden = true
        
        // Render the scene to an image
        let texture = view?.texture(from: self)
        
        // Show UI again
        topBarNode?.isHidden = false
        bottomBarNode?.isHidden = false
        
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
    
    // MARK: - UI Setup
    
    private func setupUI() {
        setupTopBar()
        setupBottomBar()
    }
    
    private func setupTopBar() {
        topBarNode?.removeFromParent()
        topBarNode = SKNode()
        topBarNode?.zPosition = 1000
        
        // Top bar background
        let topBarBG = SKShapeNode(rectOf: CGSize(width: frame.width, height: 70))
        topBarBG.position = CGPoint(x: frame.midX, y: frame.height - 35)
        topBarBG.fillColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.95)
        topBarBG.strokeColor = UIColor(white: 0.85, alpha: 1.0)
        topBarBG.lineWidth = 1
        topBarNode?.addChild(topBarBG)
        
        // Menu button (left)
        createTopBarButton(
            name: "menu",
            text: "☰",
            position: CGPoint(x: 40, y: frame.height - 35),
            color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        )
        
        // Title label (center)
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Color Line Draw"
        titleLabel.fontSize = 20
        titleLabel.fontColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.height - 43)
        titleLabel.verticalAlignmentMode = .center
        topBarNode?.addChild(titleLabel)
        
        // Undo button (right side)
        createTopBarButton(
            name: "undo",
            text: "↶",
            position: CGPoint(x: frame.width - 100, y: frame.height - 35),
            color: UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
        )
        
        // Redo button (right side)
        createTopBarButton(
            name: "redo",
            text: "↷",
            position: CGPoint(x: frame.width - 40, y: frame.height - 35),
            color: UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
        )
        
        addChild(topBarNode!)
    }
    
    private func setupBottomBar() {
        bottomBarNode?.removeFromParent()
        bottomBarNode = SKNode()
        bottomBarNode?.zPosition = 1000
        
        // Bottom bar background
        let bottomBarBG = SKShapeNode(rectOf: CGSize(width: frame.width, height: 70))
        bottomBarBG.position = CGPoint(x: frame.midX, y: 35)
        bottomBarBG.fillColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.95)
        bottomBarBG.strokeColor = UIColor(white: 0.85, alpha: 1.0)
        bottomBarBG.lineWidth = 1
        bottomBarNode?.addChild(bottomBarBG)
        
        let iconSpacing: CGFloat = frame.width / 6
        let startX: CGFloat = iconSpacing / 2
        
        // Brush/Pencil tool
        createBottomBarIcon(
            name: "pencil",
            text: "✏️",
            label: "Draw",
            position: CGPoint(x: startX, y: 35),
            selected: true
        )
        
        // Eraser tool
        createBottomBarIcon(
            name: "eraser",
            text: "⌫",
            label: "Erase",
            position: CGPoint(x: startX + iconSpacing, y: 35),
            selected: drawingMode == .eraser
        )
        
        // Brush size selector
        createBottomBarIcon(
            name: "brushSize",
            text: "●",
            label: "Size",
            position: CGPoint(x: startX + iconSpacing * 2, y: 35),
            selected: false
        )
        
        // Color palette
        createBottomBarIcon(
            name: "colorPalette",
            text: "🎨",
            label: "Color",
            position: CGPoint(x: startX + iconSpacing * 3, y: 35),
            selected: false
        )
        
        // Rainbow mode
        createBottomBarIcon(
            name: "rainbow",
            text: "🌈",
            label: "Rainbow",
            position: CGPoint(x: startX + iconSpacing * 4, y: 35),
            selected: drawingMode == .rainbow
        )
        
        // Clear canvas
        createBottomBarIcon(
            name: "clear",
            text: "🗑",
            label: "Clear",
            position: CGPoint(x: startX + iconSpacing * 5, y: 35),
            selected: false
        )
        
        addChild(bottomBarNode!)
    }
    
    private func createTopBarButton(name: String, text: String, position: CGPoint, color: UIColor) {
        let button = SKShapeNode(circleOfRadius: 22)
        button.position = position
        button.fillColor = color
        button.strokeColor = .clear
        button.name = name
        button.zPosition = 1001
        
        // Add shadow effect with a slightly darker circle behind
        let shadow = SKShapeNode(circleOfRadius: 22)
        shadow.position = CGPoint(x: 0, y: -2)
        shadow.fillColor = UIColor(white: 0, alpha: 0.1)
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        button.addChild(shadow)
        
        let label = SKLabelNode(text: text)
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        label.fontColor = .white
        label.name = name
        button.addChild(label)
        
        topBarNode?.addChild(button)
    }
    
    private func createBottomBarIcon(name: String, text: String, label: String, position: CGPoint, selected: Bool) {
        let container = SKNode()
        container.position = position
        container.name = name
        container.zPosition = 1001
        
        // Icon background circle
        let iconBG = SKShapeNode(circleOfRadius: 24)
        iconBG.fillColor = selected ? UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0) : UIColor(white: 0.95, alpha: 1.0)
        iconBG.strokeColor = selected ? UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0) : UIColor(white: 0.85, alpha: 1.0)
        iconBG.lineWidth = 2
        iconBG.name = name
        container.addChild(iconBG)
        
        // Icon emoji
        let iconLabel = SKLabelNode(text: text)
        iconLabel.fontSize = 22
        iconLabel.verticalAlignmentMode = .center
        iconLabel.name = name
        container.addChild(iconLabel)
        
        // Label below icon
        let textLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        textLabel.text = label
        textLabel.fontSize = 10
        textLabel.fontColor = selected ? UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0) : UIColor(white: 0.5, alpha: 1.0)
        textLabel.position = CGPoint(x: 0, y: -30)
        textLabel.verticalAlignmentMode = .center
        textLabel.name = name
        container.addChild(textLabel)
        
        bottomBarNode?.addChild(container)
    }
    
    // MARK: - Panel Systems
    
    private func showBrushSizePanel() {
        closeAllPanels()
        isBrushPanelOpen = true
        isPanelOpen = true
        
        brushSizePanel = SKNode()
        brushSizePanel?.zPosition = 2000
        
        // Panel background
        let panelBG = SKShapeNode(rectOf: CGSize(width: 280, height: 200), cornerRadius: 15)
        panelBG.position = CGPoint(x: frame.midX, y: frame.midY)
        panelBG.fillColor = UIColor(white: 0.95, alpha: 0.98)
        panelBG.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        panelBG.lineWidth = 3
        brushSizePanel?.addChild(panelBG)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Brush Size"
        titleLabel.fontSize = 22
        titleLabel.fontColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 70)
        brushSizePanel?.addChild(titleLabel)
        
        // Brush size options
        let sizes: [(String, CGFloat, String)] = [
            ("Thin", 2, "✏️"),
            ("Medium", 5, "🖊"),
            ("Thick", 10, "🖍"),
            ("Extra Thick", 15, "🖌")
        ]
        
        var yPos: CGFloat = frame.midY + 25
        for sizeData in sizes {
            createBrushSizeOption(
                name: "size_\(Int(sizeData.1))",
                label: sizeData.0,
                icon: sizeData.2,
                size: sizeData.1,
                position: CGPoint(x: frame.midX, y: yPos),
                selected: lineWidth == sizeData.1
            )
            yPos -= 45
        }
        
        // Close button
        createPanelCloseButton(panel: brushSizePanel!, position: CGPoint(x: frame.midX, y: frame.midY - 80))
        
        addChild(brushSizePanel!)
        animatePanelIn(brushSizePanel!)
    }
    
    private func showColorPalettePanel() {
        closeAllPanels()
        isColorPanelOpen = true
        isPanelOpen = true
        
        colorPalettePanel = SKNode()
        colorPalettePanel?.zPosition = 2000
        
        // Panel background
        let panelBG = SKShapeNode(rectOf: CGSize(width: 320, height: 380), cornerRadius: 15)
        panelBG.position = CGPoint(x: frame.midX, y: frame.midY)
        panelBG.fillColor = UIColor(white: 0.95, alpha: 0.98)
        panelBG.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        panelBG.lineWidth = 3
        colorPalettePanel?.addChild(panelBG)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Choose Color"
        titleLabel.fontSize = 22
        titleLabel.fontColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 160)
        colorPalettePanel?.addChild(titleLabel)
        
        // Color grid
        let colors: [(String, UIColor)] = [
            ("Red", .red),
            ("Orange", .orange),
            ("Yellow", .yellow),
            ("Green", .green),
            ("Cyan", UIColor(red: 0, green: 0.8, blue: 0.8, alpha: 1.0)),
            ("Blue", .blue),
            ("Purple", .purple),
            ("Magenta", .magenta),
            ("Pink", UIColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)),
            ("Brown", .brown),
            ("Black", .black),
            ("Gray", .gray)
        ]
        
        let columns = 3
        let spacing: CGFloat = 90
        let startX = frame.midX - spacing
        var row = 0
        var col = 0
        
        for colorData in colors {
            let x = startX + CGFloat(col) * spacing
            let y = frame.midY + 100 - CGFloat(row) * 75
            
            createColorOption(
                name: "color_\(colorData.0.lowercased())",
                label: colorData.0,
                color: colorData.1,
                position: CGPoint(x: x, y: y)
            )
            
            col += 1
            if col >= columns {
                col = 0
                row += 1
            }
        }
        
        // Close button
        createPanelCloseButton(panel: colorPalettePanel!, position: CGPoint(x: frame.midX, y: frame.midY - 170))
        
        addChild(colorPalettePanel!)
        animatePanelIn(colorPalettePanel!)
    }
    
    private func showMenuPanel() {
        closeAllPanels()
        isPanelOpen = true
        
        menuPanel = SKNode()
        menuPanel?.zPosition = 2000
        
        // Semi-transparent overlay
        let overlay = SKShapeNode(rectOf: CGSize(width: frame.width, height: frame.height))
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.fillColor = UIColor(white: 0, alpha: 0.5)
        overlay.strokeColor = .clear
        overlay.name = "overlay"
        menuPanel?.addChild(overlay)
        
        // Menu panel background
        let panelBG = SKShapeNode(rectOf: CGSize(width: 300, height: 400), cornerRadius: 20)
        panelBG.position = CGPoint(x: frame.midX, y: frame.midY)
        panelBG.fillColor = .white
        panelBG.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        panelBG.lineWidth = 3
        menuPanel?.addChild(panelBG)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Menu"
        titleLabel.fontSize = 28
        titleLabel.fontColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 160)
        menuPanel?.addChild(titleLabel)
        
        // Menu options
        var yPos: CGFloat = frame.midY + 80
        
        createMenuOption(name: "save", text: "💾 Save Drawing", position: CGPoint(x: frame.midX, y: yPos))
        yPos -= 60
        
        createMenuOption(name: "share", text: "📤 Share Drawing", position: CGPoint(x: frame.midX, y: yPos))
        yPos -= 60
        
        createMenuOption(name: "newDrawing", text: "📄 New Drawing", position: CGPoint(x: frame.midX, y: yPos))
        yPos -= 60
        
        createMenuOption(name: "mainMenu", text: "🏠 Main Menu", position: CGPoint(x: frame.midX, y: yPos))
        yPos -= 60
        
        createMenuOption(name: "resume", text: "✓ Resume", position: CGPoint(x: frame.midX, y: yPos), highlight: true)
        
        addChild(menuPanel!)
        animatePanelIn(menuPanel!)
    }
    
    private func createBrushSizeOption(name: String, label: String, icon: String, size: CGFloat, position: CGPoint, selected: Bool) {
        let container = SKNode()
        container.position = position
        container.name = name
        
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: 250, height: 35), cornerRadius: 8)
        bg.fillColor = selected ? UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.3) : UIColor(white: 1.0, alpha: 0.8)
        bg.strokeColor = selected ? UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0) : UIColor(white: 0.8, alpha: 1.0)
        bg.lineWidth = 2
        bg.name = name
        container.addChild(bg)
        
        // Icon
        let iconLabel = SKLabelNode(text: icon)
        iconLabel.fontSize = 20
        iconLabel.position = CGPoint(x: -100, y: -7)
        iconLabel.name = name
        container.addChild(iconLabel)
        
        // Label
        let textLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        textLabel.text = label
        textLabel.fontSize = 16
        textLabel.fontColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        textLabel.position = CGPoint(x: -50, y: -7)
        textLabel.horizontalAlignmentMode = .left
        textLabel.name = name
        container.addChild(textLabel)
        
        // Visual preview
        let preview = SKShapeNode(circleOfRadius: size)
        preview.fillColor = .black
        preview.strokeColor = .clear
        preview.position = CGPoint(x: 90, y: 0)
        preview.name = name
        container.addChild(preview)
        
        brushSizePanel?.addChild(container)
    }
    
    private func createColorOption(name: String, label: String, color: UIColor, position: CGPoint) {
        let container = SKNode()
        container.position = position
        container.name = name
        
        // Color circle
        let colorCircle = SKShapeNode(circleOfRadius: 28)
        colorCircle.fillColor = color
        colorCircle.strokeColor = UIColor(white: 0.3, alpha: 1.0)
        colorCircle.lineWidth = 3
        colorCircle.name = name
        container.addChild(colorCircle)
        
        // Label
        let textLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        textLabel.text = label
        textLabel.fontSize = 12
        textLabel.fontColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        textLabel.position = CGPoint(x: 0, y: -45)
        textLabel.name = name
        container.addChild(textLabel)
        
        colorPalettePanel?.addChild(container)
    }
    
    private func createMenuOption(name: String, text: String, position: CGPoint, highlight: Bool = false) {
        let button = SKShapeNode(rectOf: CGSize(width: 260, height: 50), cornerRadius: 12)
        button.position = position
        button.fillColor = highlight ? UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0) : UIColor(white: 0.95, alpha: 1.0)
        button.strokeColor = highlight ? .clear : UIColor(white: 0.8, alpha: 1.0)
        button.lineWidth = 2
        button.name = name
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 18
        label.fontColor = highlight ? .white : UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        label.verticalAlignmentMode = .center
        label.name = name
        button.addChild(label)
        
        menuPanel?.addChild(button)
    }
    
    private func createPanelCloseButton(panel: SKNode, position: CGPoint) {
        let button = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 10)
        button.position = position
        button.fillColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        button.strokeColor = .clear
        button.name = "closePanel"
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Done"
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "closePanel"
        button.addChild(label)
        
        panel.addChild(button)
    }
    
    private func closeAllPanels() {
        if let panel = brushSizePanel {
            animatePanelOut(panel)
        }
        if let panel = colorPalettePanel {
            animatePanelOut(panel)
        }
        if let panel = menuPanel {
            animatePanelOut(panel)
        }
        
        isPanelOpen = false
        isBrushPanelOpen = false
        isColorPanelOpen = false
    }
    
    private func animatePanelIn(_ panel: SKNode) {
        panel.setScale(0.8)
        panel.alpha = 0
        
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.2)
        scaleAction.timingMode = .easeOut
        let fadeAction = SKAction.fadeIn(withDuration: 0.2)
        
        panel.run(SKAction.group([scaleAction, fadeAction]))
    }
    
    private func animatePanelOut(_ panel: SKNode) {
        let scaleAction = SKAction.scale(to: 0.8, duration: 0.15)
        scaleAction.timingMode = .easeIn
        let fadeAction = SKAction.fadeOut(withDuration: 0.15)
        
        panel.run(SKAction.group([scaleAction, fadeAction])) {
            panel.removeFromParent()
        }
    }
    
    // MARK: - UI Interaction
    
    private func handleUITouch(at position: CGPoint) {
        let touchedNodes = nodes(at: position)
        
        for node in touchedNodes {
            guard let name = node.name else { continue }
            
            // Top bar buttons
            if name == "menu" {
                showMenuPanel()
                animateButtonPress(node)
                return
            } else if name == "undo" {
                undoLastLine()
                animateButtonPress(node)
                return
            } else if name == "redo" {
                redoLastLine()
                animateButtonPress(node)
                return
            }
            
            // Bottom bar buttons
            if name == "pencil" {
                setDrawingMode(.singleColor)
                animateButtonPress(node)
                setupBottomBar()
                return
            } else if name == "eraser" {
                setDrawingMode(.eraser)
                animateButtonPress(node)
                setupBottomBar()
                return
            } else if name == "brushSize" {
                showBrushSizePanel()
                animateButtonPress(node)
                return
            } else if name == "colorPalette" {
                showColorPalettePanel()
                animateButtonPress(node)
                return
            } else if name == "rainbow" {
                setDrawingMode(.rainbow)
                animateButtonPress(node)
                setupBottomBar()
                return
            } else if name == "clear" {
                showClearConfirmation()
                animateButtonPress(node)
                return
            }
            
            // Panel interactions
            if name == "closePanel" || name == "overlay" {
                closeAllPanels()
                return
            }
            
            // Brush size selection
            if name.hasPrefix("size_") {
                if let sizeStr = name.split(separator: "_").last,
                   let sizeValue = Double(String(sizeStr)) {
                    setLineWidth(CGFloat(sizeValue))
                    animateButtonPress(node)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.closeAllPanels()
                    }
                }
                return
            }
            
            // Color selection
            if name.hasPrefix("color_") {
                if let parent = node.parent,
                   let colorCircle = parent.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                    pickColor(colorCircle.fillColor)
                    animateButtonPress(node)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.closeAllPanels()
                    }
                }
                return
            }
            
            // Menu panel options
            if name == "save" {
                saveDrawing()
                animateButtonPress(node)
                closeAllPanels()
                return
            } else if name == "share" {
                shareDrawing()
                animateButtonPress(node)
                closeAllPanels()
                return
            } else if name == "newDrawing" {
                showNewDrawingConfirmation()
                return
            } else if name == "mainMenu" {
                returnToMenu()
                return
            } else if name == "resume" {
                closeAllPanels()
                return
            }
        }
    }
    
    private func showClearConfirmation() {
        let alert = UIAlertController(
            title: "Clear Canvas?",
            message: "This will erase your entire drawing. Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.clearScreen()
        })
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
    
    private func showNewDrawingConfirmation() {
        let alert = UIAlertController(
            title: "New Drawing?",
            message: "Starting a new drawing will clear the current canvas. Would you like to save first?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save & New", style: .default) { _ in
            self.saveDrawing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.clearScreen()
                self.closeAllPanels()
            }
        })
        alert.addAction(UIAlertAction(title: "New Without Saving", style: .destructive) { _ in
            self.clearScreen()
            self.closeAllPanels()
        })
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true)
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
}

