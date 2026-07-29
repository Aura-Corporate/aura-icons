# Changelog

## Unreleased

* **Breaking:** all 6 styles (Outline, Linear, Bold, Broken, BoldDuotone,
  LineDuotone) are now `vector_graphics` assets — the 4 previously
  font-backed styles no longer expose `IconData`. Use the new `AuraIcon`
  widget everywhere instead of `Icon(...)`.
* **Breaking:** `DuotoneIcon` renamed to `AuraIcon`; `AuraDuotoneIconData`
  renamed to `AuraIconData`. Neither is duotone-specific anymore.
* Dropped the Node.js (`fantasticon`) and Inkscape dependencies from the
  codegen pipeline entirely — `vector_graphics` renders strokes natively at
  runtime, so the stroke-to-fill conversion that existed only to produce
  font glyphs is no longer needed. The pipeline is now pure Dart.

## 1.0.0 (2026-07-29)


### Features

* aura_solar_icons vector icon package ([4403fe4](https://github.com/Aura-Corporate/aura-icons/commit/4403fe4449851c125815aab2364ee8cf037dc7db))


### Bug Fixes

* drop text labels from the icon gallery golden ([37cfeac](https://github.com/Aura-Corporate/aura-icons/commit/37cfeacf538e4c13a7194a33228cf6b8aceb9e40))
* pass --repo to gh pr edit in release workflow ([234061e](https://github.com/Aura-Corporate/aura-icons/commit/234061e826ca0d99a898ff17cfd6a5c161a6d505))

## 0.1.0

* Initial scaffold: codegen pipeline pulling icon artwork from
  `saoudi-h/solar-icons`, generating IconData-based fonts for Outline, Linear,
  Bold, Broken, and vector_graphics-based `DuotoneIcon` support for
  BoldDuotone and LineDuotone.
