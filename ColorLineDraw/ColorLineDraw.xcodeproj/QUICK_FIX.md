# Quick Fix: Photo Library Crash

## ⚠️ THE FIX

Your app crashes when saving because iOS requires a privacy description in Info.plist.

### Step-by-Step Fix:

1. **In Xcode, select your project** in the Navigator (left sidebar)
2. **Select the "ColorLineDraw" target**
3. **Click the "Info" tab**
4. **Right-click in the list and select "Add Row"** (or click the + button)
5. **Type or select:** `NSPhotoLibraryAddUsageDescription`
6. **Set the value to:** `Color Line Draw needs access to save your artwork to your photo library.`
7. **Clean and rebuild** (Cmd+Shift+K, then Cmd+B)
8. **Run the app** - it should now work!

## What I Also Fixed

Added better error handling in `GameScene.swift`:
- ✅ Detects permission-related errors specifically
- ✅ Shows a helpful alert with "Open Settings" button
- ✅ Takes users directly to Settings to enable photo access
- ✅ More user-friendly than just showing an error code

## Expected Behavior After Fix

1. **First time saving:** iOS shows permission dialog
2. **If user allows:** Drawing saves successfully with "Success! 🎉" message
3. **If user denies:** Alert with button to open Settings
4. **Share feature:** Works without special permissions (uses system share sheet)

## Quick Copy-Paste for Info.plist

If you're editing Info.plist as source code, add this inside the `<dict>` tags:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Color Line Draw needs access to save your artwork to your photo library.</string>
```

That's it! 🎨
