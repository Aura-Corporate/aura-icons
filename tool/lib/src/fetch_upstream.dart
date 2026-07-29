import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'config.dart' as config;

/// Downloads (or reuses a cached copy of) the upstream repo tarball for
/// [config.upstreamCommitSha], extracts only `packages/core/svgs/**`, and
/// returns the local directory containing the extracted `svgs/` tree.
///
/// Idempotent: if the cache directory for this SHA already contains the
/// extracted svgs, the download/extraction is skipped entirely. Switching
/// `upstreamCommitSha` in config.dart naturally invalidates the cache since
/// the cache path is keyed by SHA.
Future<Directory> fetchUpstreamSvgs({required Directory cacheRoot}) async {
  final shaCacheDir = Directory(p.join(cacheRoot.path, 'upstream', config.upstreamCommitSha));
  final svgsDir = Directory(p.join(shaCacheDir.path, 'svgs'));

  if (await svgsDir.exists() && (await svgsDir.list().toList()).isNotEmpty) {
    stderr.writeln('[fetch_upstream] using cached svgs at ${svgsDir.path}');
    return svgsDir;
  }

  final url = Uri.parse(
    'https://codeload.github.com/${config.upstreamOwner}/${config.upstreamRepo}'
    '/tar.gz/${config.upstreamCommitSha}',
  );

  stderr.writeln('[fetch_upstream] downloading $url ...');
  final client = HttpClient();
  final bytes = BytesBuilder(copy: false);
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw StateError(
        'fetch_upstream: unexpected status ${response.statusCode} for $url. '
        'Double-check upstreamCommitSha in tool/src/config.dart.',
      );
    }
    await for (final chunk in response) {
      bytes.add(chunk);
    }
  } finally {
    client.close(force: true);
  }
  stderr.writeln('[fetch_upstream] downloaded ${bytes.length} bytes, extracting...');

  final tarBytes = GZipDecoder().decodeBytes(bytes.takeBytes());
  final archive = TarDecoder().decodeBytes(tarBytes);

  // GitHub codeload tarballs wrap everything in a single top-level
  // `<repo>-<sha>/` directory; strip that plus the leading
  // `packages/core/svgs/` prefix so files land directly under svgsDir.
  final marker = '/${config.upstreamSvgsPath}/';
  var extractedCount = 0;

  await svgsDir.create(recursive: true);

  for (final entry in archive) {
    if (!entry.isFile) continue;
    final name = entry.name;
    final markerIndex = name.indexOf(marker);
    if (markerIndex == -1) continue;

    final relativePath = name.substring(markerIndex + marker.length);
    if (relativePath.isEmpty) continue;

    final outFile = File(p.join(svgsDir.path, relativePath));
    await outFile.parent.create(recursive: true);
    await outFile.writeAsBytes(entry.content as List<int>);
    extractedCount++;
  }

  if (extractedCount == 0) {
    throw StateError(
      'fetch_upstream: no files extracted under "$marker" — the upstream '
      'repo layout may have changed (expected ${config.upstreamSvgsPath}/).',
    );
  }

  stderr.writeln('[fetch_upstream] extracted $extractedCount files to ${svgsDir.path}');
  return svgsDir;
}

/// Lists the category directory names present in [svgsDir] (e.g. `arrows`,
/// `business`, ...), discovered dynamically rather than hardcoded so a new
/// upstream category shows up automatically on the next regeneration.
Future<List<String>> listCategories(Directory svgsDir) async {
  final categories = <String>[];
  await for (final entry in svgsDir.list()) {
    if (entry is Directory) {
      categories.add(p.basename(entry.path));
    }
  }
  categories.sort();
  return categories;
}
