# Build & Integration Checklist

## New Files to Add to Xcode

Make sure these new files are added to your Xcode project:

### 1. DrawingManager.swift
- [x] File created in project directory
- [ ] Added to Xcode project (drag into Navigator)
- [ ] Target membership: ColorLineDraw ✓
- [ ] Compile Sources: Should appear in Build Phases

### 2. GalleryScene.swift
- [x] File created in project directory
- [ ] Added to Xcode project (drag into Navigator)
- [ ] Target membership: ColorLineDraw ✓
- [ ] Compile Sources: Should appear in Build Phases

## Files Modified

These files were updated and should compile without issues:
- ✅ GameScene.swift
- ✅ MenuScene.swift

## Import Statements

All files should have proper imports. Verify these at the top:

**DrawingManager.swift:**
```swift
import UIKit
```

**GalleryScene.swift:**
```swift
import SpriteKit
import UIKit
```

**GameScene.swift:**
```swift
// Should already have:
import SpriteKit
import UIKit
```

## Build Steps

### If Files Aren't in Xcode Yet:

1. **In Xcode**, right-click on your project folder in Navigator
2. Choose **"Add Files to ColorLineDraw..."**
3. Select both new files:
   - DrawingManager.swift
   - GalleryScene.swift
4. Make sure **"Copy items if needed"** is checked
5. Make sure **ColorLineDraw target** is selected
6. Click **Add**

### Clean Build:

1. Product → Clean Build Folder (Cmd+Shift+K)
2. Product → Build (Cmd+B)
3. Fix any errors (shouldn't be any!)
4. Product → Run (Cmd+R)

## Potential Build Issues

### Issue: "Cannot find type 'GalleryScene' in scope"
**Solution:** Make sure GalleryScene.swift is added to the project target

### Issue: "Cannot find 'DrawingManager' in scope"
**Solution:** Make sure DrawingManager.swift is added to the project target

### Issue: "Use of undeclared type 'SavedDrawing'"
**Solution:** SavedDrawing is defined in DrawingManager.swift - add that file first

### Issue: Compile errors in GameScene.swift
**Solution:** Make sure DrawingManager.swift is in the project so GameScene can reference it

## Verification

After building, verify these methods exist:

### In GameScene:
```swift
func loadDrawing(image: UIImage, drawingId: UUID)
func exportToPhotos()
func openGallery()
```

### In GalleryScene:
```swift
func openDrawing(drawingId: UUID)
func confirmDelete(drawingId: UUID)
func createNewDrawing()
```

### In DrawingManager:
```swift
func saveDrawing(_: UIImage, drawingId: UUID?) -> SavedDrawing?
func loadDrawing(_: SavedDrawing) -> UIImage?
func deleteDrawing(_: SavedDrawing)
func getAllDrawings() -> [SavedDrawing]
```

## Runtime Testing

### First Launch Tests:
1. App launches without crash ✓
2. Main menu displays correctly ✓
3. Gallery button is clickable ✓
4. Gallery shows empty state ✓
5. Can create new drawing ✓

### Save/Load Tests:
1. Draw something ✓
2. Save to gallery (menu → Save to Gallery) ✓
3. Success message appears ✓
4. Open gallery (menu → My Gallery) ✓
5. Drawing appears with thumbnail ✓
6. Tap drawing to edit ✓
7. Drawing loads correctly ✓

### Delete Test:
1. Open gallery ✓
2. Tap × on a drawing ✓
3. Confirmation appears ✓
4. Confirm delete ✓
5. Drawing disappears ✓

## Info.plist Reminder

Don't forget the photo library permission from earlier:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Color Line Draw needs access to save your artwork to your photo library.</string>
```

This is only needed for "Export to Photos" feature.

## File Locations

Expected file structure:
```
ColorLineDraw/
├── AppDelegate.swift
├── GameViewController.swift
├── MenuScene.swift
├── GameScene.swift
├── SettingsScene.swift
├── DrawingManager.swift        ← NEW
├── GalleryScene.swift          ← NEW
└── Info.plist
```

## Success Criteria

When everything is working:
- ✅ No build errors
- ✅ No runtime crashes
- ✅ Can save drawings
- ✅ Can view gallery
- ✅ Can edit drawings
- ✅ Can delete drawings
- ✅ UI is responsive
- ✅ Safe areas respected

## Need Help?

If you encounter issues:
1. Check that all files are added to project
2. Clean build folder
3. Check target membership
4. Verify imports
5. Check console for error messages

All features should work out of the box! 🎨
