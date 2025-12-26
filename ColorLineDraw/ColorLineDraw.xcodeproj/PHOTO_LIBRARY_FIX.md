# Fix for Photo Library Save Crash

## The Problem
The app crashes when trying to save a drawing because it needs permission to access the photo library, but no usage description has been provided in Info.plist.

## Solution: Add Photo Library Usage Description

### Option 1: Using Xcode (Recommended)

1. **Open your project in Xcode**
2. **Select your target** (ColorLineDraw) in the project navigator
3. **Go to the Info tab**
4. **Add a new entry:**
   - Click the **+** button
   - Select **"Privacy - Photo Library Additions Usage Description"** from the dropdown
   - Or type: `NSPhotoLibraryAddUsageDescription`
   - Value: `"Color Line Draw needs access to save your artwork to your photo library."`

### Option 2: Edit Info.plist Directly

Open your `Info.plist` file and add this entry:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Color Line Draw needs access to save your artwork to your photo library.</string>
```

The complete entry in context would look like:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your other keys here -->
    
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Color Line Draw needs access to save your artwork to your photo library.</string>
    
    <!-- More keys below -->
</dict>
</plist>
```

## What This Does

When a user tries to save a drawing for the first time, iOS will show a permission dialog with your message:

```
"Color Line Draw" Would Like to Add Photos

Color Line Draw needs access to save your artwork to your photo library.

[Don't Allow]  [Allow]
```

## Additional Note

If you also want to let users share images (which you already have in the code), you might want to add this optional key as well (though it's not required for sharing):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Color Line Draw needs access to your photo library to save and share your artwork.</string>
```

However, for **iOS 11 and later**, the `NSPhotoLibraryAddUsageDescription` key is sufficient for saving images using `UIImageWriteToSavedPhotosAlbum`.

## After Adding the Key

1. **Clean your build** (Product > Clean Build Folder or Cmd+Shift+K)
2. **Rebuild and run** the app
3. **Try saving a drawing** - you should now see the permission dialog
4. **Grant permission** and the save should work!

## Testing

After the fix:
- ✅ First save attempt will show permission dialog
- ✅ User can grant or deny permission
- ✅ If granted, drawings save successfully with the "Success! 🎉" message
- ✅ If denied, user sees an error message and can change permissions in Settings
