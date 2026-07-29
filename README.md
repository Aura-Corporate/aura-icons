# aura_solar_icons

Solar icon set packaged as a native Flutter/Dart package, generated from the
community-maintained SVG source at
[`saoudi-h/solar-icons`](https://github.com/saoudi-h/solar-icons)
(icon artwork by 480 Design / R4IN80W, CC BY 4.0 — see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)).

🔎 [Browse every icon in the live example](https://aura-corporate.github.io/aura-icons/)
(deployed automatically from `main` — see `.github/workflows/deploy_pages.yml`).

## Styles

All 6 styles are precompiled `vector_graphics` assets, rendered through the
`AuraIcon` widget:

| Style | API |
| --- | --- |
| Outline | `AuraIcon(AuraIconsOutline.<name>)` |
| Linear | `AuraIcon(AuraIconsLinear.<name>)` |
| Bold | `AuraIcon(AuraIconsBold.<name>)` |
| Broken | `AuraIcon(AuraIconsBroken.<name>)` |
| BoldDuotone | `AuraIcon(AuraIconsBoldDuotone.<name>)` |
| LineDuotone | `AuraIcon(AuraIconsLineDuotone.<name>)` |

For the duotone styles, the accent region is the same hue as the rest of the
icon at a lower baked-in opacity (not a second distinct color), so a single
`color` parameter recolors the whole icon while preserving that contrast —
no different from how `color` works for the 4 single-tone styles.

## Usage

```dart
import 'package:aura_solar_icons/aura_solar_icons.dart';

AuraIcon(AuraIconsOutline.home, size: 24, color: Colors.black);
AuraIcon(AuraIconsBold.home, size: 24, color: Colors.black);
AuraIcon(AuraIconsBoldDuotone.home, size: 24, color: Colors.black);
```

## Regenerating

The `lib/src/generated/` and `assets/vectors/` contents are 100% generated —
never hand-edit them. To regenerate from upstream:

```bash
cd tool
dart pub get
dart run generate_icons.dart
```

No Node.js or Inkscape required — the whole pipeline is pure Dart. A daily
CI job (`.github/workflows/upstream_sync.yml`) checks for new upstream
commits and opens a PR automatically when one is found — it never
auto-merges. See [`tool/README.md`](tool/README.md) for the full pipeline
and how to bump the pinned upstream commit manually.
