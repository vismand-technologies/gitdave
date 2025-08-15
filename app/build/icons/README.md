Icon placeholders

Add your app icons here before packaging:

- Windows (ICO): put file at build/icons/icon.ico (recommended 256x256 with multiple sizes embedded)
- macOS (ICNS): put file at build/icons/icon.icns (use iconutil to convert from .iconset)
- Linux (PNG directory): place PNGs in build/icons/png with the following names/sizes:
  - 16x16.png
  - 32x32.png
  - 48x48.png
  - 64x64.png
  - 128x128.png
  - 256x256.png
  - 512x512.png

Until you add these files, electron-builder will fall back to the default Electron icon.
