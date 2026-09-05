# App-icon source art (not bundled, not generated from)

These four PNGs are the higher-fidelity source for the app icon: an Android adaptive pair
(`icon_background` + `icon_foreground`), an iOS square (`icon_ios`) and a raster fallback
(`icon_xxxhdpi`).

Nothing reads them today. The generator that ships is **`flutter_launcher_icons`**
(`flutter_launcher_icons.yaml`), and it sources from `web/*.png` instead — a flat
`adaptive_icon_background: "#37474f"` rather than this background image. A config for a second,
uninstalled generator (`icons_launcher.yaml`) pointed here and was deleted 2026-09-03: the tool was
not a dependency, and its paths did not resolve because this art sits one folder deeper.

They are kept because they are source material and the only copy: switching the Android adaptive
icon to the real background image is a deliberate design change, and this is what it would need.

The folder name is a `-` on purpose. `pubspec.yaml` bundles `assets/icons/app/` non-recursively, so
a subdirectory is excluded from the app bundle — nothing here ships to a device.
