import 'dart:io';

import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;

/// Compiles duotone SVGs (BoldDuotone, LineDuotone) into `.vec` binary
/// assets via `package:vector_graphics_compiler`'s Dart API — pure Dart, no
/// subprocess, unlike [FontBuilder]/[StrokeToFillConverter].
///
/// `currentColor` is resolved to a fixed placeholder color at compile time
/// (`vector_graphics_compiler` has no notion of a runtime-recolorable
/// placeholder — the SVG's paint is baked into the binary format). This is
/// fine for our use case: the accent sub-path's `opacity="0.5"` survives
/// compilation as a genuine alpha value on that path's paint, independent of
/// which RGB value `currentColor` resolved to. At runtime, `DuotoneIcon`
/// applies a single `ColorFilter.mode(color, BlendMode.srcIn)` over the
/// whole rendered picture, which replaces every pixel's RGB with the
/// caller's chosen color while preserving each pixel's alpha — so the
/// pre-baked 50%-opacity accent region still renders lighter than the main
/// shape, in whatever color the caller picked.
class VectorCompiler {
  Future<void> compileAll(List<VectorCompileJob> jobs) async {
    for (final job in jobs) {
      // The masking/clipping/overdraw optimizers rely on a native
      // `libpathops` boolean-path-operations library that's normally
      // located via Flutter's engine artifact cache (see
      // `initializePathOpsFromFlutterCache` upstream) — not something we
      // want this codegen tool to depend on wiring up. None of our source
      // icons use SVG masks/clip-paths, so these optimizers have nothing to
      // do here anyway; disabling them avoids the native dependency
      // entirely rather than chasing down a Flutter cache path.
      final bytes = vgc.encodeSvg(
        xml: job.svg,
        debugName: job.iconName,
        enableMaskingOptimizer: false,
        enableClippingOptimizer: false,
        enableOverdrawOptimizer: false,
      );
      await job.output.parent.create(recursive: true);
      await job.output.writeAsBytes(bytes);
    }
  }
}

class VectorCompileJob {
  const VectorCompileJob({required this.iconName, required this.svg, required this.output});
  final String iconName;

  /// The fully-assembled, standalone SVG document (see
  /// `svg_normalizer.dart`'s `assembleSvg`).
  final String svg;
  final File output;
}
