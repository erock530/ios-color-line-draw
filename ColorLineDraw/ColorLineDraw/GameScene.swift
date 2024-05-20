import SpriteKit

class GameScene: SKScene {
    var currentLine: SKShapeNode?
    var lineColor: UIColor = .red

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupClearButton()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            startLine(at: position)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            continueLine(to: position)
        }
    }

    func startLine(at position: CGPoint) {
        currentLine = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: position)
        currentLine?.path = path
        currentLine?.strokeColor = lineColor
        currentLine?.lineWidth = 5
        self.addChild(currentLine!)
    }

    func continueLine(to position: CGPoint) {
        if let path = currentLine?.path {
            let mutablePath = path.mutableCopy()
            mutablePath?.addLine(to: position)
            currentLine?.path = mutablePath
            changeLineColor()
        }
    }

    func changeLineColor() {
        lineColor = UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 1)
        currentLine?.strokeColor = lineColor
    }

    func clearScreen() {
        self.removeAllChildren()
        setupClearButton()  // Re-add the clear button after removing all children
    }

    private func setupClearButton() {
        let clearButton = SKLabelNode(fontNamed: "Helvetica")
        clearButton.text = "Clear"
        clearButton.fontSize = 24
        clearButton.fontColor = SKColor.red
        clearButton.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 50) // Position at the bottom-middle of the screen
        clearButton.name = "clearButton" // Important for identifying the node in touch events
        self.addChild(clearButton)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodesAtPoint = nodes(at: location)
            if nodesAtPoint.contains(where: { $0.name == "clearButton" }) {
                clearScreen()
            }
        }
    }
}

