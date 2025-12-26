//
//  DrawingManager.swift
//  ColorLineDraw
//
//  Manages saving and loading drawings
//

import UIKit

struct SavedDrawing: Codable {
    let id: UUID
    let imageName: String
    let thumbnailName: String
    let dateCreated: Date
    var dateModified: Date
    
    init(id: UUID = UUID(), imageName: String, thumbnailName: String, dateCreated: Date = Date()) {
        self.id = id
        self.imageName = imageName
        self.thumbnailName = thumbnailName
        self.dateCreated = dateCreated
        self.dateModified = dateCreated
    }
}

class DrawingManager {
    static let shared = DrawingManager()
    
    private let drawingsKey = "SavedDrawings"
    private let documentsDirectory: URL
    private let imagesDirectory: URL
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documentsDirectory.appendingPathComponent("Drawings", isDirectory: true)
        
        // Create drawings directory if it doesn't exist
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Save Drawing
    
    func saveDrawing(_ image: UIImage, drawingId: UUID? = nil) -> SavedDrawing? {
        let id = drawingId ?? UUID()
        let imageName = "\(id.uuidString)_full.png"
        let thumbnailName = "\(id.uuidString)_thumb.png"
        
        // Save full image
        guard let imageData = image.pngData(),
              let thumbnailData = createThumbnail(from: image)?.pngData() else {
            return nil
        }
        
        let imageURL = imagesDirectory.appendingPathComponent(imageName)
        let thumbnailURL = imagesDirectory.appendingPathComponent(thumbnailName)
        
        do {
            try imageData.write(to: imageURL)
            try thumbnailData.write(to: thumbnailURL)
            
            // Create or update drawing record
            var drawing: SavedDrawing
            if let existingDrawing = getDrawing(by: id) {
                drawing = SavedDrawing(
                    id: existingDrawing.id,
                    imageName: imageName,
                    thumbnailName: thumbnailName,
                    dateCreated: existingDrawing.dateCreated
                )
                drawing.dateModified = Date()
            } else {
                drawing = SavedDrawing(id: id, imageName: imageName, thumbnailName: thumbnailName)
            }
            
            // Update drawings list
            updateDrawingsList(with: drawing)
            
            return drawing
        } catch {
            print("Error saving drawing: \(error)")
            return nil
        }
    }
    
    // MARK: - Load Drawing
    
    func loadDrawing(_ drawing: SavedDrawing) -> UIImage? {
        let imageURL = imagesDirectory.appendingPathComponent(drawing.imageName)
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func loadThumbnail(_ drawing: SavedDrawing) -> UIImage? {
        let thumbnailURL = imagesDirectory.appendingPathComponent(drawing.thumbnailName)
        guard let imageData = try? Data(contentsOf: thumbnailURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    // MARK: - Get Drawings
    
    func getAllDrawings() -> [SavedDrawing] {
        guard let data = UserDefaults.standard.data(forKey: drawingsKey),
              let drawings = try? JSONDecoder().decode([SavedDrawing].self, from: data) else {
            return []
        }
        return drawings.sorted { $0.dateModified > $1.dateModified }
    }
    
    func getDrawing(by id: UUID) -> SavedDrawing? {
        return getAllDrawings().first { $0.id == id }
    }
    
    // MARK: - Delete Drawing
    
    func deleteDrawing(_ drawing: SavedDrawing) {
        // Delete image files
        let imageURL = imagesDirectory.appendingPathComponent(drawing.imageName)
        let thumbnailURL = imagesDirectory.appendingPathComponent(drawing.thumbnailName)
        
        try? FileManager.default.removeItem(at: imageURL)
        try? FileManager.default.removeItem(at: thumbnailURL)
        
        // Update drawings list
        var drawings = getAllDrawings()
        drawings.removeAll { $0.id == drawing.id }
        saveDrawingsList(drawings)
    }
    
    // MARK: - Private Helpers
    
    private func createThumbnail(from image: UIImage) -> UIImage? {
        let thumbnailSize = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        }
    }
    
    private func updateDrawingsList(with drawing: SavedDrawing) {
        var drawings = getAllDrawings()
        
        // Remove existing entry with same ID
        drawings.removeAll { $0.id == drawing.id }
        
        // Add new/updated drawing
        drawings.append(drawing)
        
        saveDrawingsList(drawings)
    }
    
    private func saveDrawingsList(_ drawings: [SavedDrawing]) {
        if let encoded = try? JSONEncoder().encode(drawings) {
            UserDefaults.standard.set(encoded, forKey: drawingsKey)
        }
    }
}
