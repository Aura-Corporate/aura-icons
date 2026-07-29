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

## 0.1.0

* Initial scaffold: codegen pipeline pulling icon artwork from
  `saoudi-h/solar-icons`, generating IconData-based fonts for Outline, Linear,
  Bold, Broken, and vector_graphics-based `DuotoneIcon` support for
  BoldDuotone and LineDuotone.
