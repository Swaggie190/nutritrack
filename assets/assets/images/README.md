# NutriTrack Logo Assets

This directory contains all logo and branding assets for the NutriTrack application.

## 📁 Current Assets

- **logo.png** - Main application logo (338KB)
  - Used in: App bar, splash screen, about page
  - Current size: ~1024x1024px (adjust as needed)

## 🎨 How to Replace the Logo

### Quick Replace (Keep Same Filename):
1. Replace `assets/images/logo.png` with your new logo
2. Keep the filename as `logo.png`
3. Run `flutter clean` then `flutter pub get`
4. Rebuild the app

### Add Different Logo Variants:
1. Add your logo files to this directory:
   ```
   assets/images/
   ├── logo.png          (Main logo)
   ├── logo_white.png    (White variant for dark backgrounds)
   ├── logo_icon.png     (Icon only, no text)
   └── logo_splash.png   (Splash screen logo)
   ```

2. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/logo.png
       - assets/images/logo_white.png
       - assets/images/logo_icon.png
   ```

3. Use in code:
   ```dart
   Image.asset('assets/images/logo.png', height: 100)
   ```

## ✅ Logo Specifications

### Recommended Sizes:
- **App Bar Logo**: 120x40px or similar wide format
- **Splash Screen**: 512x512px
- **App Icon** (launcher): 1024x1024px
- **Loading Screen**: 256x256px

### File Formats:
- **PNG**: Recommended (supports transparency)
- **SVG**: Not directly supported (use flutter_svg package if needed)
- **JPEG**: Only for photos, not logos

### Design Tips:
- ✅ Use PNG with transparent background
- ✅ Keep file size < 500KB for faster loading
- ✅ Ensure logo is readable at small sizes
- ✅ Test on both light and dark backgrounds
- ❌ Avoid gradients if possible (better performance)

## 🔧 Update App Launcher Icon

To change the app launcher icon:

1. Replace the icon file:
   ```
   assets/icon/app_icon.png
   ```

2. Run icon generator:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. Rebuild the app

## 📝 Code References

Logo is used in these files:
- `lib/features/Home/home.dart` - App bar
- `lib/features/auth/login_screen.dart` - Login page
- `lib/features/auth/register_screen.dart` - Registration page

Search for `logo.png` in the codebase to find all usages.

## 🎯 Quick Command Reference

```bash
# Find where logo is used
grep -r "logo.png" lib/

# Replace logo (from project root)
cp ~/my-new-logo.png assets/images/logo.png

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

---

**Need help?** Check the main project README or create an issue on GitHub.
