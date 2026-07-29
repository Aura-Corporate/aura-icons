# aura_icons codegen tool

Pulls the SVG source from a pinned commit of
[`saoudi-h/solar-icons`](https://github.com/saoudi-h/solar-icons), normalizes
it, compiles it to `vector_graphics` `.vec` assets, and generates the Dart
bindings under `../lib/src/generated/`.

## Prerequisites

Just Dart — no Node.js, no Inkscape. The whole pipeline is pure Dart
(`package:archive` for the upstream tarball, `package:vector_graphics_compiler`
for the asset compilation step).

## Running

```bash
dart pub get
dart run generate_icons.dart                        # full run, all categories
dart run generate_icons.dart --only-category=arrows  # subset, for quick validation
```

Regenerating is idempotent: it fully rebuilds `../lib/src/generated/*.g.dart`
and `../assets/vectors/**` from scratch every run. Only the vendored upstream
SVG snapshot (`.cache/upstream/<sha>/`, gitignored) is cached across runs,
keyed by the pinned commit SHA.

## Bumping the upstream commit

**Automatic**: `.github/workflows/upstream_sync.yml` runs daily (and via the
"Run workflow" button in the Actions tab), compares the pinned SHA against
upstream's current `HEAD`, and — if they differ — bumps `upstreamCommitSha`,
regenerates, and opens a PR for review. It never auto-merges. The PR is
opened via a GitHub App token (same one `release.yml` uses) rather than the
default `GITHUB_TOKEN`, specifically so `quality_check.yml` actually runs on
it (PRs opened with the default token don't trigger other workflows).

**Manual**: change `upstreamCommitSha` in `lib/src/config.dart`, update the
same value in `../THIRD_PARTY_NOTICES.md`, then re-run. Review the diff in
`../lib/src/generated/**` and `../assets/vectors/**` (new/renamed/removed
icons show up immediately) before committing.

## Known upstream data-quality gaps

`lib/src/svg_normalizer.dart`'s `hasMalformedNumericData` detects `NaN`/
`Infinity` coordinates in a source SVG (a real issue found at the pinned
commit: `Bold/logout.svg` contains a literal `-nan` coordinate, almost
certainly a Figma-export artifact) and excludes just that (style, icon) pair
rather than compiling corrupted geometry. Excluded pairs are recorded in
`../lib/src/generated/known_gaps.g.dart` and asserted by
`../test/icon_completeness_test.dart`.
